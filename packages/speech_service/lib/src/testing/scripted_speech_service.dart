import 'dart:async';

import '../speech_event.dart';
import '../speech_service.dart';

/// In-memory [SpeechService] for widget tests, unit tests and demos.
///
/// Records every call and lets the test push events with [partial],
/// [finalText], [level] and [fail]. Events may be emitted after [stop] too,
/// mirroring the real service, whose last final transcript can trail the
/// stop call.
class ScriptedSpeechService implements SpeechService {
  ScriptedSpeechService({
    this.availability = SpeechAvailability.available,
    this.locales = const [SpeechLocale(id: 'en_US', name: 'English (US)')],
    this.onStart,
  });

  /// What [initialize] reports.
  SpeechAvailability availability;

  /// What [supportedLocales] returns.
  List<SpeechLocale> locales;

  /// Error thrown by [start], when set.
  Object? startError;

  /// When set, [start] waits for this to complete before returning, which
  /// lets a test stop the session while it is still starting.
  Completer<void>? startGate;

  /// Runs after each successful [start]; demos use it to script a dialogue.
  final void Function(ScriptedSpeechService service)? onStart;

  final List<SpeechSessionConfig> startCalls = [];
  final List<SpeechSessionConfig> reconfigureCalls = [];
  int initializeCalls = 0;
  int stopCalls = 0;

  final _events = StreamController<SpeechEvent>.broadcast();
  bool _listening = false;

  @override
  Stream<SpeechEvent> get events => _events.stream;

  @override
  bool get isListening => _listening;

  @override
  Future<SpeechAvailability> initialize() async {
    initializeCalls++;
    return availability;
  }

  @override
  Future<List<SpeechLocale>> supportedLocales() async => locales;

  @override
  Future<void> start(SpeechSessionConfig config) async {
    final error = startError;
    if (error != null) throw error;
    final gate = startGate;
    if (gate != null) await gate.future;
    startCalls.add(config);
    _listening = true;
    onStart?.call(this);
  }

  @override
  void reconfigure(SpeechSessionConfig config) {
    reconfigureCalls.add(config);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    _listening = false;
  }

  @override
  Future<void> dispose() async {
    _listening = false;
    await _events.close();
  }

  /// The config of the most recent [start] call.
  SpeechSessionConfig? get lastConfig => startCalls.lastOrNull;

  void emit(SpeechEvent event) => _events.add(event);

  void partial(String text) => emit(SpeechTranscript(text, isFinal: false));

  void finalText(String text) => emit(SpeechTranscript(text, isFinal: true));

  void level(double level) => emit(SpeechSoundLevel(level));

  void fail(SpeechFailureReason reason) {
    _listening = false;
    emit(SpeechFailure(reason));
  }
}
