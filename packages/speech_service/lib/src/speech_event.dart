/// Events emitted by a [SpeechService] while a dictation session is active.
///
/// A session is a stream of utterances. Each utterance produces zero or more
/// partial [SpeechTranscript]s followed by exactly one final transcript, unless
/// nothing was said. Sound levels interleave freely. A [SpeechFailure] ends
/// the session.
sealed class SpeechEvent {
  const SpeechEvent();
}

/// Recognised text for the utterance in progress.
///
/// Partial transcripts replace each other; they are not cumulative across
/// utterances. A final transcript closes the utterance, and the next one
/// starts from an empty string.
final class SpeechTranscript extends SpeechEvent {
  const SpeechTranscript(this.text, {required this.isFinal});

  final String text;
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechTranscript &&
          text == other.text &&
          isFinal == other.isFinal;

  @override
  int get hashCode => Object.hash(text, isFinal);

  @override
  String toString() => 'SpeechTranscript("$text", isFinal: $isFinal)';
}

/// Microphone input level normalised to `0.0` (silence) .. `1.0` (loud).
final class SpeechSoundLevel extends SpeechEvent {
  const SpeechSoundLevel(this.level);

  final double level;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechSoundLevel && level == other.level;

  @override
  int get hashCode => level.hashCode;

  @override
  String toString() => 'SpeechSoundLevel($level)';
}

/// The session stopped because of an error it could not recover from.
///
/// After a failure the service is no longer listening; call
/// [SpeechService.start] again to retry.
final class SpeechFailure extends SpeechEvent {
  const SpeechFailure(this.reason, {this.detail});

  final SpeechFailureReason reason;

  /// Raw platform error code, for logging. Never shown to users.
  final String? detail;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechFailure &&
          reason == other.reason &&
          detail == other.detail;

  @override
  int get hashCode => Object.hash(reason, detail);

  @override
  String toString() => 'SpeechFailure($reason, detail: $detail)';
}

/// Why a session failed. Mapped to user-facing messages by the UI.
enum SpeechFailureReason {
  /// Microphone or speech recognition permission was denied.
  permissionDenied,

  /// No recogniser on this device (or it is disabled by a restriction).
  unavailable,

  /// The recogniser has no model for the requested locale.
  languageUnsupported,

  /// The recogniser needs the network and repeatedly failed to reach it.
  network,

  /// Anything else, after the retry budget was spent.
  unknown,
}
