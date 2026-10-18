import 'package:flutter_test/flutter_test.dart';
import 'package:speech_service/speech_service.dart';
import 'package:speech_service/testing.dart';

void main() {
  late ScriptedSpeechService primary;
  late ScriptedSpeechService fallback;
  late FallbackSpeechService service;
  late List<SpeechEvent> events;

  const config = SpeechSessionConfig(localeId: 'en-US');

  setUp(() {
    primary = ScriptedSpeechService(
      locales: const [SpeechLocale(id: 'en-US', name: 'English')],
    );
    fallback = ScriptedSpeechService(
      locales: const [
        SpeechLocale(id: 'en_US', name: 'English (US)'),
        SpeechLocale(id: 'hi_IN', name: 'Hindi'),
      ],
    );
    service = FallbackSpeechService(primary: primary, fallback: fallback);
    events = [];
    service.events.listen(events.add);
  });

  tearDown(() => service.dispose());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('uses the primary when it is available', () async {
    expect(await service.initialize(), SpeechAvailability.available);
    expect(service.active, same(primary));
    expect(fallback.initializeCalls, 0);

    await service.start(config);
    expect(primary.startCalls, hasLength(1));
    expect(service.isListening, isTrue);
    await service.stop();
    expect(primary.stopCalls, 1);
  });

  test('falls back when the primary is unavailable', () async {
    primary.availability = SpeechAvailability.unavailable;
    expect(await service.initialize(), SpeechAvailability.available);
    expect(service.active, same(fallback));

    await service.start(config);
    expect(fallback.startCalls, hasLength(1));
    expect(primary.startCalls, isEmpty);
  });

  test('a denied permission wins over an unavailable fallback', () async {
    primary.availability = SpeechAvailability.permissionDenied;
    fallback.availability = SpeechAvailability.unavailable;
    expect(await service.initialize(), SpeechAvailability.permissionDenied);
  });

  test('merges the locale lists without duplicates', () async {
    await service.initialize();
    final ids = (await service.supportedLocales()).map((l) => l.id);
    expect(ids, ['en-US', 'hi_IN']);
  });

  test('names the primary locales that came without a name', () async {
    primary.locales = const [
      SpeechLocale(id: 'en_US', name: 'en_US'),
      SpeechLocale(id: 'ja_JP', name: 'ja_JP'),
      SpeechLocale(id: 'hi-IN', name: 'हिन्दी'),
    ];
    await service.initialize();
    final locales = await service.supportedLocales();

    expect(locales.map((l) => l.id), ['en_US', 'ja_JP', 'hi-IN']);
    expect(locales.map((l) => l.displayName), [
      'English (US)',
      'ja-JP',
      'हिन्दी',
    ], reason: 'a real primary name is kept; a missing one stays the tag');
  });

  test('only lists the fallback locales when it is the active one', () async {
    primary.availability = SpeechAvailability.unavailable;
    await service.initialize();
    final ids = (await service.supportedLocales()).map((l) => l.id);
    expect(ids, ['en_US', 'hi_IN']);
  });

  test('switches to the fallback when the primary refuses to start', () async {
    await service.initialize();
    primary.startError = Exception('no model');

    await service.start(config);
    expect(service.active, same(fallback));
    expect(fallback.startCalls, hasLength(1));
    expect(service.isListening, isTrue);
  });

  test('rethrows when neither service can start', () async {
    await service.initialize();
    primary.startError = Exception('no model');
    fallback.availability = SpeechAvailability.unavailable;
    await expectLater(service.start(config), throwsException);
  });

  test('forwards events from whichever service is active', () async {
    await service.initialize();
    primary.partial('hello');
    fallback.partial('world');
    await settle();
    expect(events, const [
      SpeechTranscript('hello', isFinal: false),
      SpeechTranscript('world', isFinal: false),
    ]);
  });

  test('reconfigure and stop go to the active service', () async {
    primary.availability = SpeechAvailability.unavailable;
    await service.initialize();
    await service.start(config);
    service.reconfigure(
      config.copyWith(segmentPause: const Duration(seconds: 2)),
    );
    await service.stop();
    expect(fallback.reconfigureCalls, hasLength(1));
    expect(fallback.stopCalls, 1);
    expect(primary.stopCalls, 0);
  });

  test('throws when started before initialize', () {
    expect(() => service.start(config), throwsStateError);
  });

  test('tries the primary again on the next initialize', () async {
    await service.initialize();
    primary.startError = Exception('no model');
    await service.start(config);
    expect(service.active, same(fallback));
    await service.stop();

    primary.startError = null;
    await service.initialize();
    expect(service.active, same(primary));
  });
}
