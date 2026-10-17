import 'dart:async';

import 'package:speech_apple/speech_apple.dart';

import 'sound_level_scale.dart';
import 'speech_event.dart';
import 'speech_service.dart';

/// [SpeechService] on the iOS 26 SpeechAnalyzer, through `speech_apple`.
///
/// One native session covers the whole dictation: there is no restart loop
/// and no time limit. The native side finalizes the utterance after
/// [SpeechSessionConfig.segmentPause] of silence, so the contract of one
/// final transcript per utterance holds here too.
///
/// On other platforms, or below iOS 26, [initialize] reports
/// [SpeechAvailability.unavailable] and nothing else happens; pair it with a
/// fallback through [FallbackSpeechService].
class AppleSpeechService implements SpeechService {
  AppleSpeechService({
    SpeechApple? plugin,
    SoundLevelScale soundLevelScale = SoundLevelScale.ios,
  }) : _plugin = plugin ?? SpeechApple(),
       _soundLevelScale = soundLevelScale;

  final SpeechApple _plugin;
  final SoundLevelScale _soundLevelScale;
  final _events = StreamController<SpeechEvent>.broadcast();
  StreamSubscription<SpeechAppleEvent>? _subscription;
  bool _available = false;
  bool _wantListening = false;

  @override
  Stream<SpeechEvent> get events => _events.stream;

  @override
  bool get isListening => _wantListening;

  @override
  Future<SpeechAvailability> initialize() async {
    if (!await _plugin.isSupported()) return SpeechAvailability.unavailable;
    final granted = await _plugin.requestPermissions();
    _available = granted;
    return granted
        ? SpeechAvailability.available
        : SpeechAvailability.permissionDenied;
  }

  @override
  Future<List<SpeechLocale>> supportedLocales() async {
    if (!_available) return const [];
    final ids = await _plugin.supportedLocales();
    // The platform offers no display names; the id is what callers need.
    return [for (final id in ids) SpeechLocale(id: id, name: id)];
  }

  @override
  Future<void> start(SpeechSessionConfig config) async {
    if (!_available) {
      throw StateError('start() called before a successful initialize()');
    }
    if (_wantListening) {
      reconfigure(config);
      return;
    }
    _subscription ??= _plugin.events.listen(_onEvent);
    try {
      await _plugin.start(
        localeId: config.localeId ?? '',
        segmentPause: config.segmentPause,
      );
    } on SpeechAppleException {
      rethrow;
    }
    _wantListening = true;
  }

  @override
  void reconfigure(SpeechSessionConfig config) {
    if (_wantListening) unawaited(_plugin.setSegmentPause(config.segmentPause));
  }

  @override
  Future<void> stop() async {
    if (!_wantListening) return;
    _wantListening = false;
    await _plugin.stop();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _subscription?.cancel();
    await _events.close();
  }

  void _onEvent(SpeechAppleEvent event) {
    switch (event) {
      case SpeechAppleTranscript(:final text, :final isFinal):
        if (isFinal && text.trim().isEmpty) return;
        _emit(SpeechTranscript(text, isFinal: isFinal));
      case SpeechAppleLevel(:final decibels):
        _emit(SpeechSoundLevel(_soundLevelScale.normalize(decibels)));
      case SpeechAppleError(:final code):
        _wantListening = false;
        _emit(SpeechFailure(failureReasonForAppleCode(code), detail: code));
    }
  }

  void _emit(SpeechEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  /// Maps the plugin's error codes onto [SpeechFailureReason].
  static SpeechFailureReason failureReasonForAppleCode(String code) =>
      switch (code) {
        'unsupportedLocale' => SpeechFailureReason.languageUnsupported,
        'unsupported' => SpeechFailureReason.unavailable,
        'permission' => SpeechFailureReason.permissionDenied,
        'assets' => SpeechFailureReason.network,
        _ => SpeechFailureReason.unknown,
      };
}
