import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_apple/speech_apple.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methods = MethodChannel(SpeechApple.methodChannelName);
  const events = EventChannel(SpeechApple.eventChannelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  late List<MethodCall> calls;
  late SpeechApple speech;

  setUp(() {
    calls = [];
    speech = SpeechApple();
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methods, null);
    messenger.setMockStreamHandler(events, null);
  });

  void install(Object? Function(MethodCall call) handler) {
    messenger.setMockMethodCallHandler(methods, (call) async {
      calls.add(call);
      return handler(call);
    });
  }

  group('without a native implementation', () {
    test('is unsupported and otherwise harmless', () async {
      expect(await speech.isSupported(), isFalse);
      expect(await speech.requestPermissions(), isFalse);
      expect(await speech.supportedLocales(), isEmpty);
      await speech.setSegmentPause(const Duration(seconds: 1));
      await speech.stop();
      await expectLater(
        speech.start(localeId: '', segmentPause: const Duration(seconds: 1)),
        throwsA(
          isA<SpeechAppleException>().having(
            (e) => e.code,
            'code',
            'unsupported',
          ),
        ),
      );
    });
  });

  group('with a native implementation', () {
    test('forwards support, permission and locale queries', () async {
      install(
        (call) => switch (call.method) {
          'isSupported' => true,
          'requestPermissions' => true,
          'supportedLocales' => ['en-US', 'ru-RU'],
          _ => null,
        },
      );

      expect(await speech.isSupported(), isTrue);
      expect(await speech.requestPermissions(), isTrue);
      expect(await speech.supportedLocales(), ['en-US', 'ru-RU']);
    });

    test('start sends the locale and the pause in milliseconds', () async {
      install((_) => null);
      await speech.start(
        localeId: 'ru-RU',
        segmentPause: const Duration(milliseconds: 1400),
      );
      await speech.setSegmentPause(const Duration(seconds: 2));
      await speech.stop();

      expect(calls.map((c) => c.method), ['start', 'setSegmentPause', 'stop']);
      expect(calls.first.arguments, {
        'localeId': 'ru-RU',
        'segmentPauseMs': 1400,
      });
      expect(calls[1].arguments, {'segmentPauseMs': 2000});
    });

    test('start turns platform errors into SpeechAppleException', () async {
      install((call) {
        if (call.method == 'start') {
          throw PlatformException(
            code: 'unsupportedLocale',
            message: 'no model',
          );
        }
        return null;
      });
      await expectLater(
        speech.start(localeId: 'xx', segmentPause: const Duration(seconds: 1)),
        throwsA(
          isA<SpeechAppleException>()
              .having((e) => e.code, 'code', 'unsupportedLocale')
              .having((e) => e.message, 'message', 'no model'),
        ),
      );
    });

    test('decodes events from the stream', () async {
      messenger.setMockStreamHandler(
        events,
        MockStreamHandler.inline(
          onListen: (_, sink) {
            sink.success({
              'type': 'transcript',
              'text': 'oat',
              'isFinal': false,
            });
            sink.success({
              'type': 'transcript',
              'text': 'oat milk',
              'isFinal': true,
            });
            sink.success({'type': 'level', 'decibels': -20.5});
            sink.success({'type': 'error', 'code': 'audio', 'message': 'mic'});
            sink.success({'type': 'weird'});
            sink.endOfStream();
          },
        ),
      );

      expect(await speech.events.toList(), const [
        SpeechAppleTranscript('oat', isFinal: false),
        SpeechAppleTranscript('oat milk', isFinal: true),
        SpeechAppleLevel(-20.5),
        SpeechAppleError('audio', message: 'mic'),
        SpeechAppleError('unknown', message: 'Unexpected event {type: weird}'),
      ]);
    });
  });
}
