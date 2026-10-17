import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/dictation/dictation_commands.dart';
import 'package:note_details/src/dictation/dictation_cubit.dart';
import 'package:note_details/src/dictation/dictation_mode.dart';
import 'package:speech_service/speech_service.dart';
import 'package:speech_service/testing.dart';

import 'helpers/fake_dictation_sink.dart';

void main() {
  late ScriptedSpeechService service;
  late FakeDictationSink sink;
  late DictationCubit cubit;

  const ru = Locale('ru');
  const en = Locale('en');
  const timing = DictationTiming(
    listPause: Duration(seconds: 1),
    textPause: Duration(seconds: 2),
    initialPause: Duration(seconds: 9),
  );

  setUp(() {
    service = ScriptedSpeechService(
      locales: const [
        SpeechLocale(id: 'en_US', name: 'English'),
        SpeechLocale(id: 'ru_RU', name: 'Русский'),
      ],
    );
    sink = FakeDictationSink();
    cubit = DictationCubit(service: service, sink: sink, timing: timing);
  });

  tearDown(() async {
    await cubit.close();
    await service.dispose();
  });

  /// Lets stream events reach the cubit.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('start', () {
    test(
      'goes through starting to listening with the resolved locale',
      () async {
        final statuses = <DictationStatus>[];
        final sub = cubit.stream.listen((s) => statuses.add(s.status));

        await cubit.start(ru);
        await settle();

        expect(statuses, [DictationStatus.starting, DictationStatus.listening]);
        expect(service.initializeCalls, 1);
        expect(service.lastConfig?.localeId, 'ru_RU');
        expect(cubit.state.newLinePhrase, 'новая строка');
        await sub.cancel();
      },
    );

    test('keeps the current mode unless asked to detect it', () async {
      sink.cursorMode = DictationMode.checklist;
      await cubit.start(ru);
      expect(cubit.state.mode, DictationMode.text);
      await cubit.stop();

      await cubit.start(ru, detectMode: true);
      expect(cubit.state.mode, DictationMode.checklist);
    });

    test(
      'configures the pause for the mode and hints the voice commands',
      () async {
        sink.cursorMode = DictationMode.list;
        await cubit.start(ru, detectMode: true);

        final config = service.lastConfig!;
        expect(config.segmentPause, timing.listPause);
        expect(config.initialPause, timing.initialPause);
        expect(config.contextualPhrases, contains('новая строка'));
      },
    );

    test('has no voice commands for languages without a command set', () async {
      await cubit.start(const Locale('de'), detectMode: false);
      service.locales = const [SpeechLocale(id: 'de_DE', name: 'Deutsch')];
      expect(cubit.state.newLinePhrase, isNull);
    });

    test('fails when permission is denied, without starting', () async {
      service.availability = SpeechAvailability.permissionDenied;
      await cubit.start(en);
      expect(cubit.state.status, DictationStatus.failed);
      expect(cubit.state.problem, DictationProblem.permissionDenied);
      expect(service.startCalls, isEmpty);
    });

    test('fails when no recogniser is available', () async {
      service.availability = SpeechAvailability.unavailable;
      await cubit.start(en);
      expect(cubit.state.problem, DictationProblem.unavailable);
    });

    test('fails when the language has no recogniser locale', () async {
      await cubit.start(const Locale('ja'));
      expect(cubit.state.problem, DictationProblem.languageUnsupported);
      expect(service.startCalls, isEmpty);
    });

    test('uses the device default when locales cannot be listed', () async {
      service.locales = const [];
      await cubit.start(const Locale('ja'));
      expect(cubit.state.status, DictationStatus.listening);
      expect(service.lastConfig?.localeId, isNull);
    });

    test('fails when the service refuses to start', () async {
      service.startError = StateError('boom');
      await cubit.start(en);
      expect(cubit.state.problem, DictationProblem.unknown);
    });

    test('is ignored while already active', () async {
      await cubit.start(en);
      await cubit.start(en);
      expect(service.startCalls, hasLength(1));
    });

    test('a stop during start wins and the late session is stopped', () async {
      service.startGate = Completer<void>();
      final starting = cubit.start(en);
      await settle();
      expect(cubit.state.isStarting, isTrue);

      await cubit.stop();
      expect(cubit.state.status, DictationStatus.idle);

      service.startGate!.complete();
      await starting;
      expect(cubit.state.status, DictationStatus.idle);
      expect(service.stopCalls, 2, reason: 'once on stop, once after start');
    });

    test('clears a previous problem', () async {
      service.availability = SpeechAvailability.permissionDenied;
      await cubit.start(en);
      service.availability = SpeechAvailability.available;
      await cubit.start(en);
      expect(cubit.state.status, DictationStatus.listening);
      expect(cubit.state.problem, isNull);
    });
  });

  group('transcripts', () {
    test('shows partial text while listening', () async {
      await cubit.start(en);
      service.partial('oat');
      service.partial('oat milk');
      await settle();
      expect(cubit.state.partialText, 'oat milk');
    });

    test('ignores partial text when not listening', () async {
      await cubit.start(en);
      await cubit.stop();
      service.partial('late words');
      await settle();
      expect(cubit.state.partialText, '');
    });

    test(
      'commits a final transcript in the current mode and counts it',
      () async {
        await cubit.start(en);
        cubit.setMode(DictationMode.checklist);
        service.partial('oat milk');
        service.finalText('Oat milk.');
        await settle();

        expect(sink.inserted, [('Oat milk', DictationMode.checklist)]);
        expect(cubit.state.partialText, '');
        expect(cubit.state.committedCount, 1);
      },
    );

    test('keeps sentence punctuation in text mode', () async {
      await cubit.start(en);
      service.finalText('Call the dentist.');
      await settle();
      expect(sink.inserted.single.$1, 'Call the dentist.');
    });

    test('keeps a question mark and an ellipsis in list mode', () async {
      await cubit.start(en);
      cubit.setMode(DictationMode.list);
      service.finalText('Really?');
      service.finalText('Maybe...');
      await settle();
      expect(sink.inserted.map((e) => e.$1), ['Really?', 'Maybe...']);
    });

    test('still commits a final that trails the stop call', () async {
      await cubit.start(en);
      await cubit.stop();
      service.finalText('last words');
      await settle();
      expect(sink.inserted, [('last words', DictationMode.text)]);
    });

    test('drops blank finals', () async {
      await cubit.start(en);
      service.finalText('   ');
      await settle();
      expect(sink.inserted, isEmpty);
      expect(cubit.state.committedCount, 0);
    });
  });

  group('voice commands', () {
    test(
      'inserts the words before "new line" and then breaks the line',
      () async {
        await cubit.start(en);
        service.finalText('Buy bread, new line');
        await settle();
        expect(sink.inserted, [('Buy bread', DictationMode.text)]);
        expect(sink.newLines, 1);
      },
    );

    test('a bare command inserts nothing', () async {
      await cubit.start(ru);
      service.finalText('Новая строка');
      await settle();
      expect(sink.inserted, isEmpty);
      expect(sink.newLines, 1);
      expect(cubit.state.committedCount, 0);
    });

    test('undo reverts the last edit', () async {
      await cubit.start(ru);
      service.finalText('отмена');
      await settle();
      expect(sink.undos, 1);
    });

    test('stop pauses the session', () async {
      await cubit.start(en);
      service.finalText('stop dictation');
      await settle();
      expect(cubit.state.status, DictationStatus.idle);
      expect(service.stopCalls, 1);
    });

    test('are not recognised for languages without a command set', () async {
      service.locales = const [SpeechLocale(id: 'de_DE', name: 'Deutsch')];
      await cubit.start(const Locale('de'));
      service.finalText('Brot new line');
      await settle();
      expect(sink.inserted, [('Brot new line', DictationMode.text)]);
      expect(sink.newLines, 0);
    });
  });

  group('failures and levels', () {
    test('a service failure ends in the failed state', () async {
      await cubit.start(en);
      service.fail(SpeechFailureReason.network);
      await settle();
      expect(cubit.state.status, DictationStatus.failed);
      expect(cubit.state.problem, DictationProblem.network);
    });

    test('sound levels bypass the state and reset on stop', () async {
      await cubit.start(en);
      service.level(0.7);
      await settle();
      expect(cubit.soundLevel.value, 0.7);
      await cubit.stop();
      expect(cubit.soundLevel.value, 0);
    });
  });

  group('mode and editing', () {
    test('setMode reconfigures a live session with the new pause', () async {
      await cubit.start(en);
      cubit.setMode(DictationMode.list);
      expect(service.reconfigureCalls.single.segmentPause, timing.listPause);
      cubit.setMode(DictationMode.list);
      expect(service.reconfigureCalls, hasLength(1), reason: 'no-op repeat');
    });

    test('setMode while idle only updates the state', () {
      cubit.setMode(DictationMode.checklist);
      expect(cubit.state.mode, DictationMode.checklist);
      expect(service.reconfigureCalls, isEmpty);
    });

    test('newLine and undo go straight to the sink', () {
      cubit.newLine();
      cubit.undo();
      expect(sink.newLines, 1);
      expect(sink.undos, 1);
    });
  });

  test('close stops the service', () async {
    await cubit.start(en);
    await cubit.close();
    expect(service.stopCalls, 1);
    expect(service.isListening, isFalse);
    // Replace so tearDown closes a fresh cubit.
    cubit = DictationCubit(service: service, sink: sink, timing: timing);
  });

  test('DictationCommands are reachable through the default resolver', () {
    expect(DictationCommands.forLanguage('en'), isNotNull);
  });
}
