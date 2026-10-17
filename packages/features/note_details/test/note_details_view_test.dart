import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_details/src/l10n/note_details_localizations.dart';
import 'package:note_details/src/note_details_bloc.dart';
import 'package:note_details/src/note_details_screen.dart';
import 'package:shared/shared.dart';
import 'package:speech_service/testing.dart';

import 'helpers/fake_image_files.dart';
import 'helpers/fake_note_repository.dart';

Widget _buildView(NoteDetailsBloc bloc) {
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
      child: NoteDetailsView(speechService: ScriptedSpeechService()),
    ),
  );
}

/// Builds an app that navigates to [NoteDetailsView] when 'open' is tapped.
/// Returns the widget + captures the pop result in [result].
Widget _buildNavigationView(
  NoteDetailsBloc bloc,
  void Function(Note?) capture,
) {
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
      child: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            final result = await Navigator.of(context).push<Note?>(
              MaterialPageRoute<Note?>(
                builder: (_) => BlocProvider<NoteDetailsBloc>.value(
                  value: bloc,
                  child: NoteDetailsView(
                    speechService: ScriptedSpeechService(),
                  ),
                ),
              ),
            );
            capture(result);
          },
          child: const Text('open'),
        ),
      ),
    ),
  );
}

void main() {
  group('NoteDetailsView', () {
    // --- Initial UI elements ---

    testWidgets('renders back button, pin icon and color icon', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.push_pin_outlined), findsOneWidget);
      expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('renders title text field and quill editor with hint text', (
      tester,
    ) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      expect(find.byType(TextField), findsOneWidget); // title only
      expect(find.byType(QuillEditor), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('shows filled pin icon when note is pinned', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: true,
      );
      bloc.emit(const NoteDetailsState(isPinned: true));
      await tester.pumpWidget(_buildView(bloc));
      await tester.pump();

      expect(find.byIcon(Icons.push_pin), findsAtLeastNWidgets(1));
      await tester.pump(const Duration(seconds: 1));
    });

    // --- Text field interactions ---

    testWidgets('typing in title field updates bloc state', (tester) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      await tester.enterText(find.byType(TextField), 'Hello title');
      await tester.pump();

      expect(bloc.state.title, 'Hello title');
      await tester.pump(const Duration(seconds: 1));
    });

    // --- Back button navigation ---

    testWidgets('back button pops with null when both fields are empty', (
      tester,
    ) async {
      Note? result;
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: true,
      );
      await tester.pumpWidget(_buildNavigationView(bloc, (n) => result = n));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });

    testWidgets('back button with title only saves note', (tester) async {
      Note? result;
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: true,
      );
      await tester.pumpWidget(_buildNavigationView(bloc, (n) => result = n));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Title only');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result!.title, 'Title only');
    });

    // --- Quill content rendering ---
    //
    // QuillEditor uses a custom render pipeline so find.text() doesn't work.
    // Instead we verify the controller's document directly.

    testWidgets('loads plain text content into the editor document', (
      tester,
    ) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: false,
      );
      await tester.pumpWidget(_buildView(bloc));

      bloc.emit(
        const NoteDetailsState(
          status: NoteDetailsStatus.success,
          content: 'Hello plain text',
        ),
      );
      await tester.pump();

      final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
      expect(
        editor.controller.document.toPlainText(),
        contains('Hello plain text'),
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('loads canonical Delta JSON content into the editor document', (
      tester,
    ) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: false,
      );
      await tester.pumpWidget(_buildView(bloc));

      bloc.emit(
        const NoteDetailsState(
          status: NoteDetailsStatus.success,
          content: '{"ops":[{"insert":"Delta content\\n"}]}',
        ),
      );
      await tester.pump();

      final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
      expect(
        editor.controller.document.toPlainText(),
        contains('Delta content'),
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
      'loads legacy bare array JSON content into the editor document',
      (
        tester,
      ) async {
        final bloc = NoteDetailsBloc(
          noteRepository: FakeNoteRepository(),
          imageFiles: FakeImageFiles(),
          isNew: false,
        );
        await tester.pumpWidget(_buildView(bloc));

        bloc.emit(
          const NoteDetailsState(
            status: NoteDetailsStatus.success,
            content: '[{"insert":"Legacy content\\n"}]',
          ),
        );
        await tester.pump();

        final editor = tester.widget<QuillEditor>(find.byType(QuillEditor));
        expect(
          editor.controller.document.toPlainText(),
          contains('Legacy content'),
        );
        await tester.pump(const Duration(seconds: 1));
      },
    );

    // --- Quill controller config ---

    testWidgets('QuillController has enableExternalRichPaste disabled', (
      tester,
    ) async {
      final bloc = NoteDetailsBloc(
        noteRepository: FakeNoteRepository(),
        imageFiles: FakeImageFiles(),
        isNew: true,
      );
      await tester.pumpWidget(_buildView(bloc));

      final controllers = tester
          .widgetList<QuillEditor>(find.byType(QuillEditor))
          .map((e) => e.controller)
          .toList();

      expect(controllers, isNotEmpty);
      for (final controller in controllers) {
        final richPasteEnabled = controller
            .config
            .clipboardConfig
            ?.enableExternalRichPaste; // ignore: experimental_member_use
        expect(richPasteEnabled, isFalse);
      }
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
