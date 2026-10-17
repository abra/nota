import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_service/speech_service.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

import 'helpers/fake_speech_to_text_platform.dart';

/// Runs [body] in a fake async zone and flushes microtasks afterwards.
///
/// The service delivers events through a broadcast stream, i.e. in
/// microtasks; leaving them queued when the zone ends would stall the
/// stream's close() in tearDown.
void runFake(void Function(FakeAsync async) body) {
  fakeAsync((async) {
    body(async);
    async.flushMicrotasks();
  });
}

void main() {
  late FakeSpeechToTextPlatform platform;
  late SpeechToTextService service;
  late List<SpeechEvent> events;

  const restartDelay = Duration(milliseconds: 100);
  const config = SpeechSessionConfig(
    localeId: 'ru_RU',
    segmentPause: Duration(seconds: 1),
    initialPause: Duration(seconds: 10),
    contextualPhrases: ['новая строка'],
  );

  setUp(() {
    platform = FakeSpeechToTextPlatform();
    SpeechToTextPlatform.instance = platform;
    service = SpeechToTextService(
      plugin: SpeechToText.withMethodChannel(),
      soundLevelScale: const SoundLevelScale(silence: 0, loud: 10),
      restartDelay: restartDelay,
      maxConsecutiveFailures: 3,
    );
    events = [];
    service.events.listen(events.add);
  });

  tearDown(() => service.dispose());

  /// Initialises and starts a session, settling all microtasks.
  void startSession(FakeAsync async, {SpeechSessionConfig? with_}) {
    service.initialize();
    async.flushMicrotasks();
    service.start(with_ ?? config);
    async.flushMicrotasks();
    platform.notifyListening();
  }

  Iterable<SpeechTranscript> transcripts() => events.whereType();

  group('initialize', () {
    test('reports available when the plugin initialises', () async {
      expect(await service.initialize(), SpeechAvailability.available);
    });

    test('caches success so the plugin is set up once', () async {
      await service.initialize();
      await service.initialize();
      expect(platform.initializeCalls, 1);
    });

    test(
      'distinguishes a denied permission from a missing recogniser',
      () async {
        platform
          ..initializeResult = false
          ..permissionResult = false;
        expect(await service.initialize(), SpeechAvailability.permissionDenied);

        platform.permissionResult = true;
        expect(await service.initialize(), SpeechAvailability.unavailable);
      },
    );

    test('retries after a failure instead of caching it', () async {
      platform.initializeResult = false;
      await service.initialize();
      platform.initializeResult = true;
      expect(await service.initialize(), SpeechAvailability.available);
      expect(platform.initializeCalls, 2);
    });

    test('supportedLocales maps the platform entries', () async {
      await service.initialize();
      expect(await service.supportedLocales(), const [
        SpeechLocale(id: 'en_US', name: 'English (US)'),
        SpeechLocale(id: 'ru_RU', name: 'Русский'),
      ]);
    });

    test('supportedLocales is empty before a successful initialize', () async {
      platform.initializeResult = false;
      await service.initialize();
      expect(await service.supportedLocales(), isEmpty);
    });
  });

  group('start', () {
    test('throws when the service was not initialised', () {
      expect(() => service.start(config), throwsStateError);
    });

    test('listens in dictation mode with the session settings', () {
      runFake((async) {
        startSession(async);

        expect(service.isListening, isTrue);
        expect(platform.listenCalls, 1);
        expect(platform.lastLocaleId, 'ru_RU');
        final options = platform.lastOptions!;
        expect(options.listenMode, ListenMode.dictation);
        expect(options.partialResults, isTrue);
        expect(options.autoPunctuation, isTrue);
        expect(options.cancelOnError, isFalse);
        expect(options.pauseFor, config.initialPause);
        expect(options.listenFor, SpeechToTextService.maxUtterance);
        expect(options.contextualPhrases, ['новая строка']);
      });
    });

    test('a second start while listening only reconfigures', () {
      runFake((async) {
        startSession(async);
        service.start(
          config.copyWith(segmentPause: const Duration(seconds: 3)),
        );
        async.flushMicrotasks();
        expect(platform.listenCalls, 1);
      });
    });
  });

  group('transcripts', () {
    test('forwards partial results once per change', () {
      runFake((async) {
        startSession(async);
        platform
          ..notifyPartial('мол')
          ..notifyPartial('молоко')
          ..notifyPartial('молоко');
        async.flushMicrotasks();

        expect(transcripts(), const [
          SpeechTranscript('мол', isFinal: false),
          SpeechTranscript('молоко', isFinal: false),
        ]);
      });
    });

    test('forwards the final result and restarts after done', () {
      runFake((async) {
        startSession(async);
        platform
          ..notifyPartial('молоко')
          ..completeUtterance('молоко');
        async.flushMicrotasks();

        expect(
          transcripts().last,
          const SpeechTranscript('молоко', isFinal: true),
        );
        expect(platform.listenCalls, 1);
        async.elapse(restartDelay);
        expect(platform.listenCalls, 2, reason: 'next utterance starts');
        expect(service.isListening, isTrue);
      });
    });

    test(
      'promotes the last partial when the platform ends without a final',
      () {
        runFake((async) {
          startSession(async);
          platform
            ..notifyPartial('хлеб')
            ..notifyNotListening()
            ..notifyDoneNoResult();
          async.flushMicrotasks();

          expect(
            transcripts().last,
            const SpeechTranscript('хлеб', isFinal: true),
          );
        });
      },
    );

    test('does not emit an empty final', () {
      runFake((async) {
        startSession(async);
        platform
          ..notifyNotListening()
          ..notifyDoneNoResult();
        async.flushMicrotasks();
        expect(transcripts(), isEmpty);
        async.elapse(restartDelay);
        expect(platform.listenCalls, 2);
      });
    });

    test('closes the utterance after notListening when done never comes', () {
      runFake((async) {
        startSession(async);
        platform
          ..notifyPartial('яйца')
          ..notifyNotListening();
        async.elapse(SpeechToTextService.doneTimeout);

        expect(
          transcripts().last,
          const SpeechTranscript('яйца', isFinal: true),
        );
        async.elapse(restartDelay);
        expect(platform.listenCalls, 2);
      });
    });

    test('normalises sound levels through the scale', () {
      runFake((async) {
        startSession(async);
        platform
          ..notifySoundLevel(5)
          ..notifySoundLevel(40);
        async.flushMicrotasks();
        expect(events.whereType<SpeechSoundLevel>(), const [
          SpeechSoundLevel(0.5),
          SpeechSoundLevel(1),
        ]);
      });
    });
  });

  group('pauses', () {
    test('shortens the pause to segmentPause once speech is heard', () {
      runFake((async) {
        startSession(async);
        // Silence before any words: the long initial pause applies.
        async.elapse(const Duration(seconds: 5));
        expect(platform.stopCalls, 0);

        platform.notifyPartial('молоко');
        async.elapse(const Duration(milliseconds: 900));
        expect(platform.stopCalls, 0);
        async.elapse(const Duration(milliseconds: 200));
        expect(platform.stopCalls, 1, reason: 'segment pause elapsed');
      });
    });

    test('reconfigure applies a new segment pause mid-utterance', () {
      runFake((async) {
        startSession(async);
        platform.notifyPartial('встреча');
        service.reconfigure(
          config.copyWith(segmentPause: const Duration(seconds: 3)),
        );
        async.elapse(const Duration(milliseconds: 1500));
        expect(platform.stopCalls, 0);
        async.elapse(const Duration(seconds: 2));
        expect(platform.stopCalls, 1);
      });
    });
  });

  group('stop', () {
    test('stops the recogniser and does not restart', () {
      runFake((async) {
        startSession(async);
        service.stop();
        async.flushMicrotasks();

        expect(service.isListening, isFalse);
        expect(platform.stopCalls, 1);
        platform.completeUtterance('');
        async.elapse(const Duration(seconds: 1));
        expect(platform.listenCalls, 1);
      });
    });

    test('still delivers the final result of the last utterance', () {
      runFake((async) {
        startSession(async);
        platform.notifyPartial('кофе');
        service.stop();
        async.flushMicrotasks();
        platform.completeUtterance('кофе');
        async.flushMicrotasks();

        expect(
          transcripts().last,
          const SpeechTranscript('кофе', isFinal: true),
        );
      });
    });

    test('stops a session whose listen call was still in flight', () {
      runFake((async) {
        service.initialize();
        async.flushMicrotasks();
        service.start(config);
        // No microtask flush yet: listen() has not returned.
        service.stop();
        async.flushMicrotasks();

        expect(platform.listenCalls, 1);
        expect(platform.stopCalls, 1);
        expect(service.isListening, isFalse);
      });
    });
  });

  group('errors', () {
    test('silence errors end the utterance and restart without failing', () {
      runFake((async) {
        startSession(async);
        platform.notifyError('error_no_match');
        async.elapse(restartDelay);

        expect(events.whereType<SpeechFailure>(), isEmpty);
        expect(platform.cancelCalls, 1, reason: 'recogniser reset');
        expect(platform.listenCalls, 2);
      });
    });

    test('a permission error fails the session immediately', () {
      runFake((async) {
        startSession(async);
        platform.notifyError('error_permission', permanent: true);
        async.elapse(const Duration(seconds: 5));

        expect(events.whereType<SpeechFailure>(), [
          const SpeechFailure(
            SpeechFailureReason.permissionDenied,
            detail: 'error_permission',
          ),
        ]);
        expect(service.isListening, isFalse);
        expect(platform.listenCalls, 1);
      });
    });

    test('a language error is reported as unsupported', () {
      runFake((async) {
        startSession(async);
        platform.notifyError('error_language_not_supported');
        async.flushMicrotasks();
        expect(
          events.whereType<SpeechFailure>().single.reason,
          SpeechFailureReason.languageUnsupported,
        );
      });
    });

    test('network errors retry with backoff, then fail', () {
      runFake((async) {
        startSession(async);

        platform.notifyError('error_network');
        async.elapse(restartDelay * 2);
        expect(platform.listenCalls, 2);
        platform.notifyListening();

        platform.notifyError('error_network');
        async.elapse(restartDelay * 4);
        expect(platform.listenCalls, 3);
        platform.notifyListening();

        platform.notifyError('error_network');
        async.elapse(const Duration(seconds: 10));
        expect(platform.listenCalls, 3);
        expect(
          events.whereType<SpeechFailure>().single.reason,
          SpeechFailureReason.network,
        );
        expect(service.isListening, isFalse);
      });
    });

    test('recognised speech resets the failure count', () {
      runFake((async) {
        startSession(async);
        for (var i = 0; i < 2; i++) {
          platform.notifyError('error_network');
          async.elapse(const Duration(seconds: 2));
          platform.notifyListening();
        }
        platform
          ..notifyPartial('ok')
          ..completeUtterance('ok');
        async.elapse(restartDelay);
        platform.notifyListening();

        platform.notifyError('error_network');
        async.elapse(const Duration(seconds: 2));
        expect(events.whereType<SpeechFailure>(), isEmpty);
        expect(service.isListening, isTrue);
      });
    });

    test('a listen that throws is retried', () {
      runFake((async) {
        service.initialize();
        async.flushMicrotasks();
        platform.throwOnListen = true;
        service.start(config);
        async.flushMicrotasks();
        expect(platform.listenCalls, 1);

        platform.throwOnListen = false;
        async.elapse(restartDelay * 2);
        expect(platform.listenCalls, 2);
        expect(events.whereType<SpeechFailure>(), isEmpty);
      });
    });

    test('a recogniser that never reports listening is restarted', () {
      runFake((async) {
        service.initialize();
        async.flushMicrotasks();
        service.start(config);
        async.flushMicrotasks();
        async.elapse(SpeechToTextService.startTimeout);
        async.elapse(restartDelay * 2);
        expect(platform.listenCalls, 2);
      });
    });
  });

  test('dispose stops the session and closes the stream', () async {
    await service.initialize();
    await service.start(config);
    platform.notifyListening();
    await service.dispose();
    expect(service.isListening, isFalse);
    expect(platform.stopCalls, 1);
    await expectLater(service.events.isEmpty, completion(isTrue));
  });
}
