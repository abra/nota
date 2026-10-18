import 'dart:async';

import 'speech_event.dart';
import 'speech_service.dart';

/// Prefers [primary] and switches to [fallback] when the primary is not
/// available on this device, or refuses to start a session.
///
/// Used to put the iOS 26 SpeechAnalyzer in front of the older recognisers:
/// [initialize] picks the service for the device, [supportedLocales] merges
/// both lists so a language only the fallback knows still resolves, and a
/// [start] that the primary rejects (no model for the locale, download
/// failed) is retried on the fallback within the same call.
class FallbackSpeechService implements SpeechService {
  FallbackSpeechService({
    required SpeechService primary,
    required SpeechService fallback,
  }) : _primary = primary,
       _fallback = fallback {
    _subscriptions = [
      primary.events.listen(_events.add),
      fallback.events.listen(_events.add),
    ];
  }

  final SpeechService _primary;
  final SpeechService _fallback;
  final _events = StreamController<SpeechEvent>.broadcast();
  late final List<StreamSubscription<SpeechEvent>> _subscriptions;
  SpeechService? _active;

  /// The service currently in charge; `null` before [initialize].
  SpeechService? get active => _active;

  @override
  Stream<SpeechEvent> get events => _events.stream;

  @override
  bool get isListening => _active?.isListening ?? false;

  @override
  Future<SpeechAvailability> initialize() async {
    final primary = await _primary.initialize();
    if (primary == SpeechAvailability.available) {
      _active = _primary;
      return primary;
    }
    _active = _fallback;
    final fallback = await _fallback.initialize();
    // A denied permission is the more useful message than "unavailable".
    if (fallback != SpeechAvailability.available &&
        primary == SpeechAvailability.permissionDenied) {
      return primary;
    }
    return fallback;
  }

  @override
  Future<List<SpeechLocale>> supportedLocales() async {
    final active = _active;
    if (active == null) return const [];
    if (!identical(active, _primary)) return active.supportedLocales();
    final primary = await _primary.supportedLocales();
    // Only the fallback can list languages the primary lacks; it needs to be
    // initialised for that, which also asks for nothing new on iOS.
    if (await _fallback.initialize() != SpeechAvailability.available) {
      return primary;
    }
    final fallback = await _fallback.supportedLocales();
    // SpeechAnalyzer reports bare ids; the older recogniser has names.
    final names = {for (final locale in fallback) locale.tag: locale.name};
    final seen = <String>{};
    return [
      for (final locale in primary)
        if (seen.add(locale.tag)) _withName(locale, names[locale.tag]),
      for (final locale in fallback)
        if (seen.add(locale.tag)) locale,
    ];
  }

  @override
  Future<void> start(SpeechSessionConfig config) async {
    final active = _active;
    if (active == null) {
      throw StateError('start() called before a successful initialize()');
    }
    if (!identical(active, _primary)) return active.start(config);
    try {
      await _primary.start(config);
    } on Exception {
      if (await _fallback.initialize() != SpeechAvailability.available) {
        rethrow;
      }
      _active = _fallback;
      await _fallback.start(config);
    }
  }

  @override
  void reconfigure(SpeechSessionConfig config) => _active?.reconfigure(config);

  @override
  Future<void> stop() async => _active?.stop();

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _primary.dispose();
    await _fallback.dispose();
    await _events.close();
  }

  /// Keeps the primary's [locale] id, which is what its [start] expects,
  /// and borrows a real [name] when the primary had none.
  static SpeechLocale _withName(SpeechLocale locale, String? name) =>
      name == null || locale.displayName != locale.tag
      ? locale
      : SpeechLocale(id: locale.id, name: name);
}
