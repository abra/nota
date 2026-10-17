part of 'dictation_cubit.dart';

enum DictationStatus {
  /// Not listening; either never started or paused.
  idle,

  /// Asking for permissions and starting the recogniser.
  starting,

  /// Listening; utterances are committed as they finish.
  listening,

  /// Stopped because of [DictationState.problem].
  failed,
}

/// Why dictation stopped, mapped to a message by the UI.
enum DictationProblem {
  permissionDenied,
  unavailable,
  languageUnsupported,
  network,
  unknown,
}

const Object _kKeep = Object();

final class DictationState extends Equatable {
  const DictationState({
    this.status = DictationStatus.idle,
    this.mode = DictationMode.text,
    this.partialText = '',
    this.problem,
    this.committedCount = 0,
    this.newLinePhrase,
  });

  final DictationStatus status;
  final DictationMode mode;

  /// Words recognised so far for the utterance in progress.
  final String partialText;

  /// Set while [status] is [DictationStatus.failed].
  final DictationProblem? problem;

  /// Utterances written to the document in this session. Increments are the
  /// UI's cue for haptic feedback.
  final int committedCount;

  /// Spoken phrase that starts a new line in the session language, or `null`
  /// when the language has no voice commands.
  final String? newLinePhrase;

  bool get isListening => status == DictationStatus.listening;
  bool get isStarting => status == DictationStatus.starting;

  /// True while the microphone is, or is about to be, in use.
  bool get isActive => isStarting || isListening;

  DictationState copyWith({
    DictationStatus? status,
    DictationMode? mode,
    String? partialText,
    Object? problem = _kKeep,
    int? committedCount,
    Object? newLinePhrase = _kKeep,
  }) => DictationState(
    status: status ?? this.status,
    mode: mode ?? this.mode,
    partialText: partialText ?? this.partialText,
    problem: identical(problem, _kKeep)
        ? this.problem
        : problem as DictationProblem?,
    committedCount: committedCount ?? this.committedCount,
    newLinePhrase: identical(newLinePhrase, _kKeep)
        ? this.newLinePhrase
        : newLinePhrase as String?,
  );

  @override
  List<Object?> get props => [
    status,
    mode,
    partialText,
    problem,
    committedCount,
    newLinePhrase,
  ];

  @override
  String toString() =>
      'DictationState(status: $status, mode: $mode, '
      'partial: "$partialText", problem: $problem, '
      'committed: $committedCount)';
}
