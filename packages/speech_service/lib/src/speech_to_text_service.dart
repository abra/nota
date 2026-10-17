import 'dart:async';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'sound_level_scale.dart';
import 'speech_event.dart';
import 'speech_service.dart';

/// [SpeechService] backed by the `speech_to_text` plugin: SFSpeechRecognizer
/// on iOS, SpeechRecognizer on Android.
///
/// The platform recognisers deliver one utterance per `listen` call and stop
/// on their own after a pause or a time limit. This class turns that into a
/// continuous session: whenever the recogniser finishes an utterance, the
/// next `listen` starts after [restartDelay], until [stop] is called or an
/// error is fatal. The gap between utterances is where dictated list items
/// split, so the pause length is part of [SpeechSessionConfig].
///
/// Utterance lifecycle, as seen from the plugin:
///
/// 1. `listen` → status `listening`.
/// 2. Partial results while the user speaks. The first words shorten the
///    pause from [SpeechSessionConfig.initialPause] to `segmentPause`.
/// 3. Silence for `segmentPause` → the plugin stops the recogniser → status
///    `notListening` → final result → status `done`.
/// 4. `done` → schedule the next `listen`.
///
/// Two watchdogs cover platforms that skip a step: one waits for `listening`
/// after `listen`, the other waits for `done` after `notListening`. Errors
/// that mean "nothing was said" just end the utterance; network and other
/// errors are retried [maxConsecutiveFailures] times before a
/// [SpeechFailure] ends the session.
class SpeechToTextService implements SpeechService {
  SpeechToTextService({
    SpeechToText? plugin,
    SoundLevelScale? soundLevelScale,
    this.restartDelay = const Duration(milliseconds: 250),
    this.maxConsecutiveFailures = 3,
  }) : _plugin = plugin ?? SpeechToText(),
       _soundLevelScale =
           soundLevelScale ??
           SoundLevelScale.forPlatform(defaultTargetPlatform);

  /// Upper bound on one utterance; the platform usually stops much earlier.
  static const maxUtterance = Duration(minutes: 5);

  /// How long the plugin waits for a final result after the recogniser
  /// stopped before promoting the last partial result to final.
  static const finalTimeout = Duration(milliseconds: 1500);

  /// How long to wait for the `listening` status after `listen` returns.
  static const startTimeout = Duration(seconds: 4);

  /// How long to wait for `done` after `notListening`. Must exceed
  /// [finalTimeout] so the plugin gets its chance to deliver the final.
  static const doneTimeout = Duration(milliseconds: 2500);

  /// Pause between utterances. Lets the previous recogniser instance release
  /// the microphone before the next one claims it.
  final Duration restartDelay;

  /// Consecutive recoverable errors tolerated before giving up.
  final int maxConsecutiveFailures;

  final SpeechToText _plugin;
  final SoundLevelScale _soundLevelScale;
  final _events = StreamController<SpeechEvent>.broadcast();

  SpeechAvailability? _availability;
  SpeechSessionConfig? _config;

  /// True between [start] and [stop]; drives the restart loop.
  bool _wantListening = false;

  /// True while a `listen` call is in flight.
  bool _startingListen = false;

  /// True from a successful `listen` until the utterance is done.
  bool _sessionActive = false;

  Timer? _restartTimer;
  Timer? _startWatchdog;
  Timer? _doneWatchdog;
  int _consecutiveFailures = 0;

  // Per-utterance bookkeeping.
  bool _heardSpeech = false;
  bool _finalDelivered = false;
  String _lastPartial = '';

  @override
  Stream<SpeechEvent> get events => _events.stream;

  @override
  bool get isListening => _wantListening;

  @override
  Future<SpeechAvailability> initialize() async {
    // Only a success is cached: a user who denied permission may grant it in
    // Settings and come back, and the next attempt must notice.
    if (_availability == SpeechAvailability.available) return _availability!;
    try {
      final ready = await _plugin.initialize(
        onError: _onError,
        onStatus: _onStatus,
        finalTimeout: finalTimeout,
        options: [SpeechToText.androidNoBluetooth],
      );
      if (ready) return _availability = SpeechAvailability.available;
      final hasPermission = await _plugin.hasPermission;
      return _availability = hasPermission
          ? SpeechAvailability.unavailable
          : SpeechAvailability.permissionDenied;
    } catch (_) {
      return _availability = SpeechAvailability.unavailable;
    }
  }

  @override
  Future<List<SpeechLocale>> supportedLocales() async {
    if (_availability != SpeechAvailability.available) return const [];
    try {
      final locales = await _plugin.locales();
      return [
        for (final locale in locales)
          SpeechLocale(id: locale.localeId, name: locale.name),
      ];
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> start(SpeechSessionConfig config) async {
    if (_availability != SpeechAvailability.available) {
      throw StateError('start() called before a successful initialize()');
    }
    if (_wantListening) {
      reconfigure(config);
      return;
    }
    _config = config;
    _wantListening = true;
    _consecutiveFailures = 0;
    await _listen();
  }

  @override
  void reconfigure(SpeechSessionConfig config) {
    final previous = _config;
    _config = config;
    final pauseChanged = previous?.segmentPause != config.segmentPause;
    if (pauseChanged && _wantListening && _heardSpeech) _applySegmentPause();
  }

  @override
  Future<void> stop() async {
    _wantListening = false;
    _cancelTimers();
    if (_plugin.isListening) {
      // `stop` (not `cancel`) so the words said so far still arrive as a
      // final result; the plugin promotes the last partial if needed.
      await _guard(_plugin.stop());
    }
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _events.close();
  }

  Future<void> _listen() async {
    final config = _config;
    if (config == null ||
        !_wantListening ||
        _startingListen ||
        _sessionActive ||
        _plugin.isListening) {
      return;
    }
    _startingListen = true;
    _heardSpeech = false;
    _finalDelivered = false;
    _lastPartial = '';
    try {
      await _plugin.listen(
        onResult: _onResult,
        onSoundLevelChange: _onSoundLevel,
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
          // Errors are classified here; letting the plugin cancel on its
          // own notion of "permanent" would drop recoverable sessions.
          cancelOnError: false,
          autoPunctuation: config.autoPunctuation,
          pauseFor: config.initialPause,
          listenFor: maxUtterance,
          localeId: config.localeId,
          contextualPhrases: config.contextualPhrases.isEmpty
              ? null
              : config.contextualPhrases,
        ),
      );
      _sessionActive = true;
      if (!_wantListening) {
        // stop() arrived while listen() was in flight.
        await _guard(_plugin.stop());
        return;
      }
      _startWatchdog?.cancel();
      _startWatchdog = Timer(startTimeout, _onStartTimedOut);
    } catch (_) {
      _retryOrFail(SpeechFailureReason.unknown, 'listen failed');
    } finally {
      _startingListen = false;
    }
  }

  void _onResult(SpeechRecognitionResult result) {
    final text = result.recognizedWords;
    if (!_heardSpeech && text.trim().isNotEmpty) {
      _heardSpeech = true;
      _consecutiveFailures = 0;
      _applySegmentPause();
    }
    if (result.finalResult) {
      _deliverFinal(text);
    } else if (text != _lastPartial) {
      _lastPartial = text;
      _emit(SpeechTranscript(text, isFinal: false));
    }
  }

  void _onStatus(String status) {
    switch (status) {
      case SpeechToText.listeningStatus:
        _startWatchdog?.cancel();
        _startWatchdog = null;
      case SpeechToText.notListeningStatus:
        _doneWatchdog?.cancel();
        _doneWatchdog = Timer(doneTimeout, _endUtterance);
      case SpeechToText.doneStatus:
        _endUtterance();
    }
  }

  void _onError(SpeechRecognitionError error) {
    final message = error.errorMsg;
    switch (_classify(message)) {
      case _ErrorKind.silence:
        // Nothing was said (or the recogniser gave up waiting): move on.
        _endUtterance(cancelRecogniser: true);
      case _ErrorKind.permission:
        _fail(SpeechFailureReason.permissionDenied, message);
      case _ErrorKind.language:
        _fail(SpeechFailureReason.languageUnsupported, message);
      case _ErrorKind.unavailable:
        _fail(SpeechFailureReason.unavailable, message);
      case _ErrorKind.network:
        _retryOrFail(SpeechFailureReason.network, message);
      case _ErrorKind.other:
        _retryOrFail(SpeechFailureReason.unknown, message);
    }
  }

  void _onSoundLevel(double raw) {
    _emit(SpeechSoundLevel(_soundLevelScale.normalize(raw)));
  }

  void _onStartTimedOut() {
    _startWatchdog = null;
    if (_plugin.isListening) return;
    _retryOrFail(SpeechFailureReason.unknown, 'recogniser did not start');
  }

  /// Closes the current utterance and, if the session is still wanted,
  /// schedules the next one.
  void _endUtterance({bool cancelRecogniser = false}) {
    _cancelTimers(keepRestart: true);
    _sessionActive = false;
    _finishUtterance();
    if (cancelRecogniser && _plugin.isListening) {
      // After an error the plugin may still believe it is listening, which
      // would block the next listen(); cancel resets it.
      unawaited(_guard(_plugin.cancel()));
    }
    _scheduleRestart(restartDelay);
  }

  /// Promotes the last partial result to final when the platform never sent
  /// one, so no spoken words are lost between utterances.
  void _finishUtterance() {
    if (!_finalDelivered) _deliverFinal(_lastPartial);
    _lastPartial = '';
  }

  void _deliverFinal(String text) {
    if (_finalDelivered) return;
    _finalDelivered = true;
    if (text.trim().isEmpty) return;
    _emit(SpeechTranscript(text, isFinal: true));
  }

  void _retryOrFail(SpeechFailureReason reason, String detail) {
    _consecutiveFailures++;
    if (_consecutiveFailures >= maxConsecutiveFailures) {
      _fail(reason, detail);
      return;
    }
    _cancelTimers(keepRestart: true);
    _sessionActive = false;
    _finishUtterance();
    if (_plugin.isListening) unawaited(_guard(_plugin.cancel()));
    // Exponential backoff: 2×, 4×, … the restart delay.
    _scheduleRestart(restartDelay * (1 << _consecutiveFailures));
  }

  void _fail(SpeechFailureReason reason, String detail) {
    _wantListening = false;
    _sessionActive = false;
    _cancelTimers();
    _finishUtterance();
    if (_plugin.isListening) unawaited(_guard(_plugin.cancel()));
    _emit(SpeechFailure(reason, detail: detail));
  }

  void _scheduleRestart(Duration delay) {
    if (!_wantListening) return;
    _restartTimer?.cancel();
    _restartTimer = Timer(delay, () {
      _restartTimer = null;
      unawaited(_listen());
    });
  }

  void _applySegmentPause() {
    final pause = _config?.segmentPause;
    if (pause == null || !_plugin.isListening) return;
    try {
      _plugin.changePauseFor(pause);
    } catch (_) {
      // The recogniser stopped between the check and the call; the next
      // utterance starts with the configured pauses anyway.
    }
  }

  void _cancelTimers({bool keepRestart = false}) {
    _startWatchdog?.cancel();
    _startWatchdog = null;
    _doneWatchdog?.cancel();
    _doneWatchdog = null;
    if (!keepRestart) {
      _restartTimer?.cancel();
      _restartTimer = null;
    }
  }

  void _emit(SpeechEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  /// Plugin calls can throw after the recogniser was torn down by the
  /// platform; none of them carry information worth surfacing.
  static Future<void> _guard(Future<void> call) => call.catchError((_) {});

  static _ErrorKind _classify(String message) {
    if (message.startsWith('error_no_match') ||
        message.startsWith('error_speech_timeout') ||
        message.startsWith('error_retry')) {
      return _ErrorKind.silence;
    }
    if (message.startsWith('error_permission')) return _ErrorKind.permission;
    if (message.startsWith('error_language')) return _ErrorKind.language;
    if (message.startsWith('error_speech_recognizer_disabled')) {
      return _ErrorKind.unavailable;
    }
    if (message.startsWith('error_network') ||
        message.startsWith('error_server') ||
        message.startsWith('error_too_many_requests')) {
      return _ErrorKind.network;
    }
    return _ErrorKind.other;
  }
}

enum _ErrorKind { silence, permission, language, unavailable, network, other }
