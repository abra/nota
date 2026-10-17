import 'dart:async';

import 'package:speech_apple/speech_apple.dart';

/// Scriptable [SpeechApple] with no channels behind it.
class FakeSpeechApple extends SpeechApple {
  bool supported = true;
  bool permission = true;
  List<String> locales = const ['en-US', 'ru-RU'];
  SpeechAppleException? startError;

  final List<({String localeId, Duration pause})> startCalls = [];
  final List<Duration> pauseChanges = [];
  int stopCalls = 0;

  final _events = StreamController<SpeechAppleEvent>.broadcast();

  @override
  Future<bool> isSupported() async => supported;

  @override
  Future<bool> requestPermissions() async => permission;

  @override
  Future<List<String>> supportedLocales() async => locales;

  @override
  Future<void> start({
    required String localeId,
    required Duration segmentPause,
  }) async {
    final error = startError;
    if (error != null) throw error;
    startCalls.add((localeId: localeId, pause: segmentPause));
  }

  @override
  Future<void> setSegmentPause(Duration pause) async => pauseChanges.add(pause);

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Stream<SpeechAppleEvent> get events => _events.stream;

  void emit(SpeechAppleEvent event) => _events.add(event);

  Future<void> close() => _events.close();
}
