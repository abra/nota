import 'dart:async';
import 'dart:ui' show Locale;

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart' show DictationLanguage, DictationPause;
import 'package:speech_service/speech_service.dart';

import 'dictation_commands.dart';
import 'dictation_mode.dart';
import 'dictation_sink.dart';

part 'dictation_state.dart';

/// Pauses that split dictation into utterances.
///
/// Lists want a short pause so each item appears right after it is spoken.
/// Prose tolerates a longer one: a thinking pause mid-sentence should not
/// cost the first word of the next clause to the recogniser restart.
final class DictationTiming {
  const DictationTiming({
    this.listPause = const Duration(milliseconds: 1400),
    this.textPause = const Duration(milliseconds: 2500),
    this.initialPause = const Duration(seconds: 20),
  });

  /// The timing behind a [DictationPause] preference.
  factory DictationTiming.forPause(DictationPause pause) => switch (pause) {
    DictationPause.short => const DictationTiming(
      listPause: Duration(milliseconds: 1000),
      textPause: Duration(milliseconds: 2000),
    ),
    DictationPause.normal => const DictationTiming(),
    DictationPause.long => const DictationTiming(
      listPause: Duration(milliseconds: 2000),
      textPause: Duration(milliseconds: 3500),
    ),
  };

  final Duration listPause;
  final Duration textPause;

  /// Silence tolerated before the first words; see
  /// [SpeechSessionConfig.initialPause].
  final Duration initialPause;

  Duration pauseFor(DictationMode mode) => mode.isList ? listPause : textPause;
}

/// User-adjustable dictation behaviour, derived from the preferences.
final class DictationSettings {
  const DictationSettings({
    this.timing = const DictationTiming(),
    this.voiceCommands = true,
    this.language,
  });

  final DictationTiming timing;

  /// Whether spoken commands are recognised and hinted at.
  final bool voiceCommands;

  /// BCP 47 tag of the language to listen in; `null` follows the app
  /// language given to [DictationCubit.start].
  final String? language;
}

/// Drives one dictation session.
///
/// Starts and stops the [SpeechService], exposes partial transcripts and
/// commits finished utterances to the [DictationSink] according to the
/// current [DictationMode]. Spoken commands at the end of an utterance are
/// executed after the text before them is inserted. Both the recogniser and
/// the commands use the dictation language, which may differ from the app
/// language.
class DictationCubit extends Cubit<DictationState> {
  DictationCubit({
    required SpeechService service,
    required DictationSink sink,
    DictationCommandSet? Function(String languageCode) commandsFor =
        DictationCommands.forLanguage,
    DictationSettings settings = const DictationSettings(),
  }) : _service = service,
       _sink = sink,
       _commandsFor = commandsFor,
       _settings = settings,
       super(const DictationState());

  final SpeechService _service;
  final DictationSink _sink;
  final DictationCommandSet? Function(String languageCode) _commandsFor;
  DictationSettings _settings;
  Locale? _appLocale;
  String? _languageCode;

  DictationSettings get settings => _settings;

  /// Microphone level, `0..1`. Kept out of [state] because it changes many
  /// times per second and only the level meter needs it.
  final ValueNotifier<double> soundLevel = ValueNotifier(0);

  StreamSubscription<SpeechEvent>? _subscription;
  DictationCommandSet? _commands;
  String? _localeId;

  /// Incremented by every [start] and [stop] so a start that is still
  /// awaiting the platform notices it has been superseded.
  int _startToken = 0;

  /// Starts listening in [DictationSettings.language], or in [appLocale]
  /// when the settings leave the language to the app.
  ///
  /// With [detectMode] the mode follows the line under the cursor, so
  /// dictation continues the structure the user was writing. Without it the
  /// current mode is kept (resume after a pause).
  Future<void> start(Locale appLocale, {bool detectMode = false}) async {
    if (state.isActive) return;
    _appLocale = appLocale;
    await _run(detectMode ? _sink.modeAtCursor() : state.mode);
  }

  /// The language the settings ask for: the chosen one or the app's.
  String get _requestedLanguage =>
      _settings.language ?? _appLocale!.toLanguageTag();

  Future<void> _run(DictationMode mode) async {
    final token = ++_startToken;
    final tag = _requestedLanguage;
    emit(
      state.copyWith(
        status: DictationStatus.starting,
        mode: mode,
        partialText: '',
        problem: null,
        language: tag,
      ),
    );

    final availability = await _service.initialize();
    if (_isSuperseded(token)) return;
    switch (availability) {
      case SpeechAvailability.available:
        break;
      case SpeechAvailability.permissionDenied:
        return _fail(DictationProblem.permissionDenied);
      case SpeechAvailability.unavailable:
        return _fail(DictationProblem.unavailable);
    }

    final locales = await _service.supportedLocales();
    if (_isSuperseded(token)) return;
    String? localeId;
    if (locales.isNotEmpty) {
      localeId = resolveSpeechLocaleIdForTag(available: locales, tag: tag);
      if (localeId == null) return _fail(DictationProblem.languageUnsupported);
    } else if (_settings.language != null) {
      // The platform could not enumerate its locales. A language the user
      // picked goes through as is and the recogniser judges it.
      localeId = tag;
    }
    // Otherwise the device default is the best remaining guess.
    _localeId = localeId;
    _languageCode = DictationLanguage.languageCodeOf(tag);
    _commands = _resolveCommands();
    _subscription ??= _service.events.listen(_onEvent);

    try {
      await _service.start(_configFor(mode));
    } catch (e, st) {
      addError(e, st);
      if (!_isSuperseded(token)) _fail(DictationProblem.unknown);
      return;
    }
    if (_isSuperseded(token)) {
      // Stopped while the recogniser was starting. A newer start that is
      // still running owns the recogniser now and must keep it.
      if (!state.isActive) await _service.stop();
      return;
    }
    emit(
      state.copyWith(
        status: DictationStatus.listening,
        newLinePhrase: _commands?.primaryPhrase(DictationCommand.newLine),
        language: localeId == null ? tag : speechLocaleTag(localeId),
      ),
    );
  }

  /// Restarts the session in the language of the current settings. The
  /// utterance in progress still lands in the note: stopping the recogniser
  /// delivers its final transcript.
  Future<void> _restart() async {
    _startToken++;
    soundLevel.value = 0;
    emit(
      state.copyWith(
        status: DictationStatus.starting,
        partialText: '',
        problem: null,
        language: _requestedLanguage,
      ),
    );
    await _service.stop();
    // A stop() or close() in the meantime wins.
    if (isClosed || !state.isStarting) return;
    await _run(state.mode);
  }

  /// Stops listening. The last utterance may still be committed afterwards.
  Future<void> stop() async {
    _startToken++;
    soundLevel.value = 0;
    if (state.status != DictationStatus.idle) {
      emit(state.copyWith(status: DictationStatus.idle, partialText: ''));
    }
    await _service.stop();
  }

  void setMode(DictationMode mode) {
    if (mode == state.mode) return;
    emit(state.copyWith(mode: mode));
    if (state.isListening) _service.reconfigure(_configFor(mode));
  }

  /// Applies new preferences, to the running session as well.
  ///
  /// A different language restarts a running or failed session in it; the
  /// other settings apply without a restart.
  void updateSettings(DictationSettings settings) {
    final languageChanged = settings.language != _settings.language;
    _settings = settings;
    if (languageChanged &&
        _appLocale != null &&
        _requestedLanguage != state.language) {
      if (state.isActive || state.status == DictationStatus.failed) {
        unawaited(_restart());
        return;
      }
      // Paused: show the new language now; the next start listens in it.
      emit(state.copyWith(language: _requestedLanguage));
    }
    _commands = _resolveCommands();
    if (state.isListening) {
      _service.reconfigure(_configFor(state.mode));
      emit(
        state.copyWith(
          newLinePhrase: _commands?.primaryPhrase(DictationCommand.newLine),
        ),
      );
    }
  }

  void newLine() => _sink.newLine();

  void undo() => _sink.undo();

  @override
  Future<void> close() async {
    _startToken++;
    await _subscription?.cancel();
    soundLevel.dispose();
    await _service.stop();
    return super.close();
  }

  bool _isSuperseded(int token) =>
      isClosed || token != _startToken || !state.isStarting;

  DictationCommandSet? _resolveCommands() {
    final language = _languageCode;
    if (language == null || !_settings.voiceCommands) return null;
    return _commandsFor(language);
  }

  SpeechSessionConfig _configFor(DictationMode mode) => SpeechSessionConfig(
    localeId: _localeId,
    segmentPause: _settings.timing.pauseFor(mode),
    initialPause: _settings.timing.initialPause,
    contextualPhrases: _commands?.allPhrases ?? const [],
  );

  void _onEvent(SpeechEvent event) {
    switch (event) {
      case SpeechTranscript(:final text, isFinal: false):
        if (state.isListening) emit(state.copyWith(partialText: text));
      case SpeechTranscript(:final text, isFinal: true):
        _commit(text);
      case SpeechSoundLevel(:final level):
        soundLevel.value = level;
      case SpeechFailure(:final reason):
        _fail(_problemFor(reason));
    }
  }

  /// Writes a finished utterance and runs the command at its end, if any.
  void _commit(String utterance) {
    final match = _commands?.match(utterance);
    final text = _clean(match?.remainder ?? utterance, state.mode);
    var committed = state.committedCount;
    if (text.isNotEmpty) {
      _sink.insert(text, state.mode);
      committed++;
    }
    emit(state.copyWith(partialText: '', committedCount: committed));
    switch (match?.command) {
      case DictationCommand.newLine:
        _sink.newLine();
      case DictationCommand.undo:
        _sink.undo();
      case DictationCommand.stop:
        unawaited(stop());
      case null:
        break;
    }
  }

  /// Trims the utterance; list items also lose a trailing full stop that
  /// auto-punctuation adds to every short phrase.
  static String _clean(String text, DictationMode mode) {
    var cleaned = text.trim();
    if (mode.isList &&
        cleaned.endsWith('.') &&
        !cleaned.endsWith('..') &&
        cleaned.length > 1) {
      cleaned = cleaned.substring(0, cleaned.length - 1).trimRight();
    }
    return cleaned;
  }

  void _fail(DictationProblem problem) {
    soundLevel.value = 0;
    emit(
      state.copyWith(
        status: DictationStatus.failed,
        problem: problem,
        partialText: '',
      ),
    );
  }

  static DictationProblem _problemFor(SpeechFailureReason reason) =>
      switch (reason) {
        SpeechFailureReason.permissionDenied =>
          DictationProblem.permissionDenied,
        SpeechFailureReason.unavailable => DictationProblem.unavailable,
        SpeechFailureReason.languageUnsupported =>
          DictationProblem.languageUnsupported,
        SpeechFailureReason.network => DictationProblem.network,
        SpeechFailureReason.unknown => DictationProblem.unknown,
      };
}
