import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

/// Scriptable stand-in for the platform side of the `speech_to_text` plugin.
///
/// Tests install it with `SpeechToTextPlatform.instance = fake` and drive the
/// plugin through the `notify*` helpers, which call the same callbacks the
/// method channel would.
class FakeSpeechToTextPlatform extends SpeechToTextPlatform {
  bool initializeResult = true;
  bool permissionResult = true;
  bool listenResult = true;
  bool throwOnListen = false;
  List<String> localeEntries = const ['en_US:English (US)', 'ru_RU:Русский'];

  int initializeCalls = 0;
  int listenCalls = 0;
  int stopCalls = 0;
  int cancelCalls = 0;
  String? lastLocaleId;
  SpeechListenOptions? lastOptions;

  @override
  Future<bool> hasPermission() async => permissionResult;

  @override
  Future<bool> hasOnDeviceSupport({String? localeId}) async => false;

  @override
  Future<bool> initialize({
    debugLogging = false,
    List<SpeechConfigOption>? options,
  }) async {
    initializeCalls++;
    return initializeResult;
  }

  @override
  Future<bool> listen({
    String? localeId,
    partialResults = true,
    onDevice = false,
    int listenMode = 0,
    sampleRate = 0,
    SpeechListenOptions? options,
  }) async {
    listenCalls++;
    lastLocaleId = localeId;
    lastOptions = options;
    if (throwOnListen) {
      throw PlatformException(code: 'listenFailed', message: 'busy');
    }
    return listenResult;
  }

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> cancel() async => cancelCalls++;

  @override
  Future<List<dynamic>> locales() async => localeEntries;

  // ── Scripting helpers ─────────────────────────────────────────────────────

  void notifyListening() => onStatus!(SpeechToText.listeningStatus);

  void notifyNotListening() => onStatus!(SpeechToText.notListeningStatus);

  void notifyDone() => onStatus!(SpeechToText.doneStatus);

  void notifyDoneNoResult() => onStatus!('doneNoResult');

  void notifyPartial(String words) =>
      onTextRecognition!(_resultJson(words, ResultType.partial));

  void notifyFinal(String words) =>
      onTextRecognition!(_resultJson(words, ResultType.finalResult));

  void notifyError(String message, {bool permanent = false}) =>
      onError!(jsonEncode({'errorMsg': message, 'permanent': permanent}));

  void notifySoundLevel(double level) => onSoundLevel!(level);

  /// The full platform sequence for one utterance that ends with [words].
  void completeUtterance(String words) {
    notifyNotListening();
    notifyFinal(words);
    notifyDone();
  }

  static String _resultJson(String words, ResultType type) => jsonEncode({
    'alternates': [
      {'recognizedWords': words, 'confidence': 0.9},
    ],
    'resultType': type.value,
  });
}
