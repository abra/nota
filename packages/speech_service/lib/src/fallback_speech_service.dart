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
    final seen = {for (final locale in primary) _normalize(locale.id)};
    // Only the fallback can list languages the primary lacks; it needs to be
    // initialised for that, which also asks for nothing new on iOS.
    if (await _fallback.initialize() != SpeechAvailability.available) {
      return primary;
    }
    return [
      ...primary,
      for (final locale in await _fallback.supportedLocales())
        if (seen.add(_normalize(locale.id))) locale,
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

  static String _normalize(String id) => id.toLowerCase().replaceAll('-', '_');
}
