import 'speech_event.dart';

/// Outcome of [SpeechService.initialize].
enum SpeechAvailability {
  /// Permissions granted and a recogniser is ready.
  available,

  /// The user denied microphone or speech recognition access.
  permissionDenied,

  /// No recogniser on this device.
  unavailable,
}

/// A locale the device recogniser can listen in.
final class SpeechLocale {
  const SpeechLocale({required this.id, required this.name});

  /// Platform identifier, e.g. `en_US`. Passed back verbatim in
  /// [SpeechSessionConfig.localeId].
  final String id;

  /// Human-readable name in the device language.
  final String name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SpeechLocale && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SpeechLocale($id, "$name")';
}

/// Settings for one continuous dictation session.
final class SpeechSessionConfig {
  const SpeechSessionConfig({
    this.localeId,
    this.segmentPause = const Duration(milliseconds: 1400),
    this.initialPause = const Duration(seconds: 20),
    this.autoPunctuation = true,
    this.contextualPhrases = const [],
  });

  /// Recogniser locale; `null` uses the device default.
  final String? localeId;

  /// Silence that ends the current utterance once speech has been heard.
  ///
  /// This is what splits dictation into list items: speak, pause, speak.
  final Duration segmentPause;

  /// Silence tolerated before the first words of an utterance.
  ///
  /// Kept long so an idle microphone does not churn through sessions (on
  /// Android every session start plays the system prompt sound).
  final Duration initialPause;

  /// Let the recogniser insert punctuation. Supported on iOS 16+ and recent
  /// Android recognisers; ignored elsewhere.
  final bool autoPunctuation;

  /// Phrases the recogniser should favour, such as voice commands.
  final List<String> contextualPhrases;

  SpeechSessionConfig copyWith({
    String? localeId,
    Duration? segmentPause,
    Duration? initialPause,
    bool? autoPunctuation,
    List<String>? contextualPhrases,
  }) => SpeechSessionConfig(
    localeId: localeId ?? this.localeId,
    segmentPause: segmentPause ?? this.segmentPause,
    initialPause: initialPause ?? this.initialPause,
    autoPunctuation: autoPunctuation ?? this.autoPunctuation,
    contextualPhrases: contextualPhrases ?? this.contextualPhrases,
  );

  @override
  String toString() =>
      'SpeechSessionConfig(localeId: $localeId, '
      'segmentPause: ${segmentPause.inMilliseconds} ms, '
      'initialPause: ${initialPause.inMilliseconds} ms, '
      'autoPunctuation: $autoPunctuation)';
}

/// Continuous speech recognition.
///
/// Platform recognisers work one utterance at a time and stop on their own
/// after a pause. A [SpeechService] hides that: after [start] it keeps
/// listening, utterance after utterance, until [stop] is called or a
/// [SpeechFailure] is emitted on [events].
///
/// Call [initialize] first; it asks for permissions and reports whether a
/// recogniser is usable. [start] throws [StateError] if it was not.
abstract interface class SpeechService {
  /// Requests permissions and prepares the recogniser. Safe to call again.
  Future<SpeechAvailability> initialize();

  /// Locales the recogniser can listen in; empty when unknown.
  Future<List<SpeechLocale>> supportedLocales();

  /// Transcripts, sound levels and failures of the current session.
  Stream<SpeechEvent> get events;

  /// True between [start] and [stop] (or a failure). The underlying
  /// recogniser may be between utterances; that is invisible to callers.
  bool get isListening;

  /// Starts a continuous session. Reconfigures the running session instead
  /// if one is already active.
  Future<void> start(SpeechSessionConfig config);

  /// Applies [config] to the running session. The pause change takes effect
  /// immediately when possible, otherwise from the next utterance.
  void reconfigure(SpeechSessionConfig config);

  /// Ends the session. The final transcript of the utterance in progress may
  /// still arrive on [events] shortly after this completes.
  Future<void> stop();

  /// Stops the session and closes [events].
  Future<void> dispose();
}
