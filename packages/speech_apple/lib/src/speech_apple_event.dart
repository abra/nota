/// Events the native session sends over the event channel.
sealed class SpeechAppleEvent {
  const SpeechAppleEvent();

  /// Decodes a channel payload; unknown shapes become [SpeechAppleError].
  factory SpeechAppleEvent.fromMap(Map<Object?, Object?> map) {
    switch (map['type']) {
      case 'transcript':
        return SpeechAppleTranscript(
          map['text'] as String? ?? '',
          isFinal: map['isFinal'] as bool? ?? false,
        );
      case 'level':
        return SpeechAppleLevel((map['decibels'] as num?)?.toDouble() ?? -160);
      case 'error':
        return SpeechAppleError(
          map['code'] as String? ?? 'unknown',
          message: map['message'] as String?,
        );
      default:
        return SpeechAppleError('unknown', message: 'Unexpected event $map');
    }
  }
}

/// Text for the utterance in progress; volatile until [isFinal].
final class SpeechAppleTranscript extends SpeechAppleEvent {
  const SpeechAppleTranscript(this.text, {required this.isFinal});

  final String text;
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechAppleTranscript &&
          text == other.text &&
          isFinal == other.isFinal;

  @override
  int get hashCode => Object.hash(text, isFinal);

  @override
  String toString() => 'SpeechAppleTranscript("$text", isFinal: $isFinal)';
}

/// Microphone level in decibels relative to full scale (about −60..0).
final class SpeechAppleLevel extends SpeechAppleEvent {
  const SpeechAppleLevel(this.decibels);

  final double decibels;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechAppleLevel && decibels == other.decibels;

  @override
  int get hashCode => decibels.hashCode;

  @override
  String toString() => 'SpeechAppleLevel($decibels dB)';
}

/// The session failed; codes mirror the native `DictationError`.
final class SpeechAppleError extends SpeechAppleEvent {
  const SpeechAppleError(this.code, {this.message});

  final String code;
  final String? message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpeechAppleError &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => Object.hash(code, message);

  @override
  String toString() => 'SpeechAppleError($code, $message)';
}
