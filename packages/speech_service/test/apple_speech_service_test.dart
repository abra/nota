import 'package:flutter_test/flutter_test.dart';
import 'package:speech_apple/speech_apple.dart';
import 'package:speech_service/speech_service.dart';

import 'helpers/fake_speech_apple.dart';

void main() {
  late FakeSpeechApple plugin;
  late AppleSpeechService service;
  late List<SpeechEvent> events;

  const config = SpeechSessionConfig(
    localeId: 'ru-RU',
    segmentPause: Duration(milliseconds: 1400),
  );

  setUp(() {
    plugin = FakeSpeechApple();
    service = AppleSpeechService(plugin: plugin);
    events = [];
    service.events.listen(events.add);
  });

  tearDown(() async {
    await service.dispose();
    await plugin.close();
  });

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('initialize', () {
    test('is unavailable where SpeechAnalyzer is missing', () async {
      plugin.supported = false;
      expect(await service.initialize(), SpeechAvailability.unavailable);
      expect(await service.supportedLocales(), isEmpty);
    });

    test('reports a denied microphone', () async {
      plugin.permission = false;
      expect(await service.initialize(), SpeechAvailability.permissionDenied);
    });

    test('is available with permission and lists the locales', () async {
      expect(await service.initialize(), SpeechAvailability.available);
      expect(
        await service.supportedLocales(),
        const [
          SpeechLocale(id: 'en-US', name: 'en-US'),
          SpeechLocale(id: 'ru-RU', name: 'ru-RU'),
        ],
      );
    });
  });

  group('session', () {
    test('start passes the locale and pause, stop ends it', () async {
      await service.initialize();
      await service.start(config);
      expect(service.isListening, isTrue);
      expect(plugin.startCalls.single.localeId, 'ru-RU');
      expect(
        plugin.startCalls.single.pause,
        const Duration(milliseconds: 1400),
      );

      await service.stop();
      expect(service.isListening, isFalse);
      expect(plugin.stopCalls, 1);
      await service.stop();
      expect(plugin.stopCalls, 1, reason: 'idempotent');
    });

    test('a null locale means the device default', () async {
      await service.initialize();
      await service.start(const SpeechSessionConfig());
      expect(plugin.startCalls.single.localeId, '');
    });

    test('throws before initialize', () {
      expect(() => service.start(config), throwsStateError);
    });

    test('a second start only reconfigures', () async {
      await service.initialize();
      await service.start(config);
      await service.start(
        config.copyWith(segmentPause: const Duration(seconds: 3)),
      );
      expect(plugin.startCalls, hasLength(1));
      expect(plugin.pauseChanges, [const Duration(seconds: 3)]);
    });

    test('reconfigure is ignored while idle', () async {
      await service.initialize();
      service.reconfigure(config);
      expect(plugin.pauseChanges, isEmpty);
    });

    test('propagates a refused start', () async {
      await service.initialize();
      plugin.startError = const SpeechAppleException('unsupportedLocale');
      await expectLater(
        service.start(config),
        throwsA(isA<SpeechAppleException>()),
      );
      expect(service.isListening, isFalse);
    });
  });

  group('events', () {
    test('maps transcripts, levels and errors', () async {
      await service.initialize();
      await service.start(config);
      plugin
        ..emit(const SpeechAppleTranscript('мол', isFinal: false))
        ..emit(const SpeechAppleTranscript('молоко', isFinal: true))
        ..emit(const SpeechAppleTranscript('  ', isFinal: true))
        ..emit(const SpeechAppleLevel(-30))
        ..emit(const SpeechAppleError('assets', message: 'offline'));
      await settle();

      expect(events, const [
        SpeechTranscript('мол', isFinal: false),
        SpeechTranscript('молоко', isFinal: true),
        SpeechSoundLevel(0.5),
        SpeechFailure(SpeechFailureReason.network, detail: 'assets'),
      ]);
      expect(service.isListening, isFalse, reason: 'an error ends the session');
    });

    test('maps every native error code', () {
      expect(
        AppleSpeechService.failureReasonForAppleCode('unsupportedLocale'),
        SpeechFailureReason.languageUnsupported,
      );
      expect(
        AppleSpeechService.failureReasonForAppleCode('unsupported'),
        SpeechFailureReason.unavailable,
      );
      expect(
        AppleSpeechService.failureReasonForAppleCode('permission'),
        SpeechFailureReason.permissionDenied,
      );
      expect(
        AppleSpeechService.failureReasonForAppleCode('audio'),
        SpeechFailureReason.unknown,
      );
    });
  });
}
