import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/dictation/dictation_cubit.dart';
import 'package:note_details/src/l10n/note_details_localizations.dart';
import 'package:note_details/src/note_details_bloc.dart';
import 'package:note_details/src/note_details_screen.dart';
import 'package:speech_service/speech_service.dart';
import 'package:speech_service/testing.dart';

import 'helpers/fake_image_files.dart';
import 'helpers/fake_note_repository.dart';

Widget _buildView(
  NoteDetailsBloc bloc,
  ScriptedSpeechService speech, {
  KeepScreenAwake? keepScreenAwake,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      NoteDetailsLocalizations.delegate,
      FlutterQuillLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: BlocProvider<NoteDetailsBloc>.value(
      value: bloc,
      child: NoteDetailsView(
        speechService: speech,
        keepScreenAwake: keepScreenAwake,
      ),
    ),
  );
}

NoteDetailsBloc _newNoteBloc() => NoteDetailsBloc(
  noteRepository: FakeNoteRepository(),
  imageFiles: FakeImageFiles(),
  isNew: true,
);

/// Lets stream events reach the cubit and the frame settle.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pumpAndSettle();
}

void main() {
  group('Dictation', () {
    late NoteDetailsBloc bloc;
    late ScriptedSpeechService speech;

    setUp(() {
      bloc = _newNoteBloc();
      speech = ScriptedSpeechService();
    });

    tearDown(() async {
      await bloc.close();
      await speech.dispose();
    });

    Future<void> openDictation(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Dictate'));
      await _settle(tester);
    }

    testWidgets('toolbar offers a dictate button next to the colours', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      expect(find.byTooltip('Dictate'), findsOneWidget);
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('tapping dictate opens the panel and starts a session', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);

      expect(speech.initializeCalls, 1);
      expect(speech.startCalls, hasLength(1));
      expect(speech.lastConfig?.localeId, 'en_US');
      expect(find.byTooltip('Checklist'), findsOneWidget);
      expect(find.byTooltip('Pause dictation'), findsOneWidget);
      expect(find.textContaining('Listening'), findsOneWidget);
      expect(
        find.byIcon(Icons.mic_rounded),
        findsNWidgets(3),
        reason: 'toolbar toggle, level meter and pause button',
      );
    });

    testWidgets('shows the partial transcript and commits the final one', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);

      speech.partial('oat milk');
      await _settle(tester);
      expect(find.text('oat milk'), findsOneWidget);

      speech.finalText('Oat milk');
      await _settle(tester);
      expect(find.text('oat milk'), findsNothing);
      expect(bloc.state.content, contains('Oat milk'));
    });

    testWidgets('mode buttons switch the mode and shape the inserted text', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);

      await tester.tap(find.byTooltip('Checklist'));
      await _settle(tester);
      expect(speech.reconfigureCalls, hasLength(1));
      expect(find.textContaining('pause between items'), findsOneWidget);

      speech.finalText('Lemons.');
      await _settle(tester);
      expect(bloc.state.content, contains('Lemons'));
      expect(bloc.state.content, contains('"list":"unchecked"'));
      expect(bloc.state.content, isNot(contains('Lemons.')));
    });

    testWidgets('pause stops the session, resume starts it again', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);

      await tester.tap(find.byTooltip('Pause dictation'));
      await _settle(tester);
      expect(speech.stopCalls, 1);
      expect(
        find.text('Paused. Tap the microphone to continue'),
        findsOneWidget,
      );
      expect(find.byTooltip('Resume dictation'), findsOneWidget);

      await tester.tap(find.byTooltip('Resume dictation'));
      await _settle(tester);
      expect(speech.startCalls, hasLength(2));
      expect(find.byTooltip('Pause dictation'), findsOneWidget);
    });

    testWidgets('closing the panel ends the session', (tester) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);

      await tester.tap(find.byTooltip('Dictate'));
      await _settle(tester);
      expect(speech.stopCalls, 1);
      // The panel stays in the tree while collapsed; it must be out of reach.
      expect(find.byTooltip('Checklist').hitTestable(), findsNothing);
      expect(find.byIcon(Icons.mic_rounded), findsNothing);
    });

    testWidgets('formatting can be opened while the session keeps running', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);

      await tester.tap(find.byTooltip('Formatting'));
      await _settle(tester);
      expect(speech.stopCalls, 0);
      expect(find.byTooltip('Bold'), findsOneWidget);
      // Only the toolbar glyph is left, and it shows the live microphone.
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);

      // Words still land in the note meanwhile.
      speech.finalText('Milk');
      await _settle(tester);
      expect(bloc.state.content, contains('Milk'));

      // Coming back shows the transcript panel without restarting.
      await tester.tap(find.byTooltip('Dictate'));
      await _settle(tester);
      expect(speech.startCalls, hasLength(1));
      expect(find.byTooltip('Pause dictation'), findsOneWidget);
    });

    testWidgets('list formatting applied while dictating switches the mode', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);
      expect(
        speech.lastConfig?.segmentPause,
        const DictationTiming().textPause,
      );

      await tester.tap(find.byTooltip('Formatting'));
      await _settle(tester);
      await tester.tap(find.byTooltip('Checked list'));
      await _settle(tester);
      expect(
        speech.reconfigureCalls.single.segmentPause,
        const DictationTiming().listPause,
      );

      speech.finalText('Milk');
      speech.finalText('Bread');
      await _settle(tester);
      expect(bloc.state.content, contains('"list":"unchecked"'));
      expect(bloc.state.content, contains('Bread'));
    });

    testWidgets('a paused session does not resume when its panel reappears', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);
      await tester.tap(find.byTooltip('Pause dictation'));
      await _settle(tester);

      await tester.tap(find.byTooltip('Formatting'));
      await _settle(tester);
      await tester.tap(find.byTooltip('Dictate'));
      await _settle(tester);
      expect(speech.startCalls, hasLength(1));
      expect(find.byTooltip('Resume dictation'), findsOneWidget);

      // Closing the panel with the mic button is still the way to end it.
      await tester.tap(find.byTooltip('Dictate'));
      await _settle(tester);
      expect(find.byTooltip('Checklist').hitTestable(), findsNothing);
    });

    testWidgets('explains a denied permission inside the panel', (
      tester,
    ) async {
      speech.availability = SpeechAvailability.permissionDenied;
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);

      expect(
        find.text('Allow microphone and speech recognition access in Settings'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.mic_off_rounded), findsOneWidget);
      expect(speech.startCalls, isEmpty);
    });

    testWidgets('reports a session failure', (tester) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);

      speech.fail(SpeechFailureReason.network);
      await _settle(tester);
      expect(
        find.text('Speech recognition needs a network connection'),
        findsOneWidget,
      );
      expect(find.byTooltip('Resume dictation'), findsOneWidget);
    });

    testWidgets('keeps the screen awake exactly while the session is active', (
      tester,
    ) async {
      final calls = <bool>[];
      await tester.pumpWidget(
        _buildView(bloc, speech, keepScreenAwake: (on) async => calls.add(on)),
      );
      await openDictation(tester);
      expect(calls, [true]);

      await tester.tap(find.byTooltip('Dictate'));
      await _settle(tester);
      expect(calls, [true, false]);
    });

    testWidgets('the panel return button breaks the line', (tester) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);
      speech.finalText('Hello');
      await _settle(tester);

      // The panel sits above the toolbar, so its return button comes first.
      await tester.tap(find.byTooltip('New line').first);
      await _settle(tester);
      expect(bloc.state.content, contains(r'Hello\n\n'));
    });

    testWidgets('a trailing final after pause still lands in the note', (
      tester,
    ) async {
      await tester.pumpWidget(_buildView(bloc, speech));
      await openDictation(tester);
      await tester.tap(find.byTooltip('Pause dictation'));
      await _settle(tester);

      speech.finalText('last words');
      await _settle(tester);
      expect(bloc.state.content, contains('last words'));
    });
  });

  group('Toolbar width', () {
    testWidgets('drops the return button when the bar cannot fit it', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final bloc = _newNoteBloc();
      final speech = ScriptedSpeechService();
      addTearDown(() async {
        await bloc.close();
        await speech.dispose();
      });
      await tester.pumpWidget(_buildView(bloc, speech));

      expect(find.byTooltip('New line'), findsNothing);
      expect(find.byTooltip('Dictate'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'no overflow');
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('keeps the return button on regular widths', (tester) async {
      final bloc = _newNoteBloc();
      final speech = ScriptedSpeechService();
      addTearDown(() async {
        await bloc.close();
        await speech.dispose();
      });
      await tester.pumpWidget(_buildView(bloc, speech));
      expect(find.byTooltip('New line'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
