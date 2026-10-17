import 'dart:async';

import 'package:flutter/services.dart';

import 'speech_apple_event.dart';

/// Thrown when the native session refuses to start.
///
/// [code] is one of `unsupported`, `unsupportedLocale`, `assets`, `audio`,
/// `arguments` or `unknown`.
class SpeechAppleException implements Exception {
  const SpeechAppleException(this.code, [this.message]);

  final String code;
  final String? message;

  @override
  String toString() => 'SpeechAppleException($code, $message)';
}

/// Continuous on-device dictation through the iOS 26 SpeechAnalyzer.
///
/// Every method is safe to call on other platforms: without a native
/// implementation [isSupported] is false and the rest are no-ops.
class SpeechApple {
  SpeechApple({MethodChannel? methodChannel, EventChannel? eventChannel})
    : _methods = methodChannel ?? const MethodChannel(methodChannelName),
      _events = eventChannel ?? const EventChannel(eventChannelName);

  static const methodChannelName = 'io.github.abra.nota/speech_apple';
  static const eventChannelName = 'io.github.abra.nota/speech_apple/events';

  final MethodChannel _methods;
  final EventChannel _events;
  Stream<SpeechAppleEvent>? _stream;

  /// Whether the device runs iOS 26 or later with the Speech framework.
  Future<bool> isSupported() async {
    try {
      return await _methods.invokeMethod<bool>('isSupported') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Asks for microphone access; SpeechAnalyzer needs nothing else.
  Future<bool> requestPermissions() async {
    try {
      return await _methods.invokeMethod<bool>('requestPermissions') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  /// BCP-47 identifiers the on-device transcriber supports.
  Future<List<String>> supportedLocales() async {
    try {
      final ids = await _methods.invokeListMethod<String>('supportedLocales');
      return ids ?? const [];
    } on MissingPluginException {
      return const [];
    }
  }

  /// Starts listening. An empty [localeId] means the device locale.
  ///
  /// Downloads the speech model on first use, which can take a while.
  /// Throws [SpeechAppleException] when the session cannot start.
  Future<void> start({
    required String localeId,
    required Duration segmentPause,
  }) async {
    try {
      await _methods.invokeMethod<void>('start', {
        'localeId': localeId,
        'segmentPauseMs': segmentPause.inMilliseconds,
      });
    } on PlatformException catch (e) {
      throw SpeechAppleException(e.code, e.message);
    } on MissingPluginException {
      throw const SpeechAppleException(
        'unsupported',
        'No native implementation',
      );
    }
  }

  /// Changes the silence that ends an utterance in the running session.
  Future<void> setSegmentPause(Duration pause) async {
    try {
      await _methods.invokeMethod<void>('setSegmentPause', {
        'segmentPauseMs': pause.inMilliseconds,
      });
    } on PlatformException {
      // Not listening any more; the next start carries the new pause.
    } on MissingPluginException {
      // No native side.
    }
  }

  /// Stops listening. The final transcript may still arrive on [events].
  Future<void> stop() async {
    try {
      await _methods.invokeMethod<void>('stop');
    } on PlatformException {
      // Already stopped.
    } on MissingPluginException {
      // No native side.
    }
  }

  /// Transcripts, levels and errors of the running session.
  Stream<SpeechAppleEvent> get events => _stream ??= _events
      .receiveBroadcastStream()
      .map((raw) => SpeechAppleEvent.fromMap(raw as Map<Object?, Object?>));
}
