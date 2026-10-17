import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:note_list/src/l10n/note_list_localizations.dart';
import 'package:note_list/src/note_list_bloc.dart';
import 'package:note_list/src/note_list_screen.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_image_files.dart';
import 'helpers/fake_note_repository.dart';

class _MockPreferencesService extends Mock implements PreferencesService {}

Note _note(String id, {String content = 'body', String? title}) => Note(
  id: id,
  title: title,
  content: content,
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

void main() {
  late _MockPreferencesService mockPrefs;
  late StreamController<Preferences> prefsController;

  setUp(() {
    mockPrefs = _MockPreferencesService();
    prefsController = StreamController<Preferences>.broadcast();
    when(() => mockPrefs.current).thenReturn(const Preferences());
    when(() => mockPrefs.stream).thenAnswer((_) => prefsController.stream);
  });

  tearDown(() => prefsController.close());

  NoteListBloc makeBloc({List<Note> notes = const [], Preferences? prefs}) {
    if (prefs != null) when(() => mockPrefs.current).thenReturn(prefs);
    return NoteListBloc(
      noteRepository: FakeNoteRepository(notes: notes),
      preferencesService: mockPrefs,
      imageFiles: FakeImageFiles(),
    );
  }

  Widget buildView({
    required NoteListBloc bloc,
    Future<Note?> Function(Note)? onNotePressed,
    Future<Note?> Function()? onAddPressed,
    Future<Note?> Function()? onAddLongPressed,
    void Function(BuildContext)? onSettingsPressed,
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        NoteListLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider<NoteListBloc>.value(
        value: bloc,
        child: NoteListView(
          onNotePressed: onNotePressed,
          onAddPressed: onAddPressed,
          onAddLongPressed: onAddLongPressed,
          onSettingsPressed: onSettingsPressed,
        ),
      ),
    );
  }

  group('NoteListView', () {
    // --- Loading ---

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.loading));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // --- Empty state ---

    testWidgets('shows empty state message when no notes', (tester) async {
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pump();

      expect(find.text('No notes yet'), findsOneWidget);
    });

    // --- Failure ---

    testWidgets('shows error message and retry button on failure', (
      tester,
    ) async {
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.failure));
      await tester.pump();

      expect(find.text('Failed to load notes'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button clears failure and shows empty state', (
      tester,
    ) async {
      final bloc = makeBloc(); // empty repo → success with no notes
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.failure));
      await tester.pump();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('No notes yet'), findsOneWidget);
    });

    // --- Grid / list views ---

    testWidgets('shows masonry grid with note content when viewMode is grid', (
      tester,
    ) async {
      final notes = [
        _note('1', content: 'note one'),
        _note('2', content: 'note two'),
      ];
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(
        NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          noteViewMode: NoteViewMode.grid,
        ),
      );
      await tester.pump();

      expect(find.byType(SliverMasonryGrid), findsOneWidget);
      expect(find.text('note one'), findsOneWidget);
      expect(find.text('note two'), findsOneWidget);
    });

    testWidgets('shows list with note content when viewMode is list', (
      tester,
    ) async {
      final notes = [_note('1', content: 'list note')];
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(
        NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          noteViewMode: NoteViewMode.list,
        ),
      );
      await tester.pump();

      expect(find.byType(SliverList), findsOneWidget);
      expect(find.text('list note'), findsOneWidget);
    });

    // --- Bottom bar ---

    testWidgets('shows search field, settings and add buttons', (tester) async {
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('holding the add button invokes onAddLongPressed', (
      tester,
    ) async {
      final bloc = makeBloc();
      var taps = 0;
      var holds = 0;
      await tester.pumpWidget(
        buildView(
          bloc: bloc,
          onAddPressed: () async {
            taps++;
            return null;
          },
          onAddLongPressed: () async {
            holds++;
            return null;
          },
        ),
      );
      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pumpAndSettle();

      await tester.longPress(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(holds, 1);
      expect(taps, 0, reason: 'a hold is not a tap');
    });

    testWidgets('onAddPressed is invoked when add button is tapped', (
      tester,
    ) async {
      var called = false;
      final bloc = makeBloc();
      await tester.pumpWidget(
        buildView(
          bloc: bloc,
          onAddPressed: () async {
            called = true;
            return null;
          },
        ),
      );

      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('onSettingsPressed is invoked when settings button is tapped', (
      tester,
    ) async {
      var called = false;
      final bloc = makeBloc();
      await tester.pumpWidget(
        buildView(
          bloc: bloc,
          onSettingsPressed: (_) {
            called = true;
          },
        ),
      );

      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pump();

      expect(called, isTrue);
    });

    // --- Search ---

    testWidgets('typing in search field shows clear button', (tester) async {
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsNothing);

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);

      // flush 300ms debounce timer to avoid "timer still pending" assertion
      await tester.pump(const Duration(milliseconds: 350));
    });

    testWidgets('tapping search clear button clears the field', (tester) async {
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(const NoteListState(status: NoteListStatus.success));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump(const Duration(milliseconds: 350)); // flush debounce

      expect(find.text('hello'), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    // --- Selection mode ---

    testWidgets('long press on note card enters selection mode', (
      tester,
    ) async {
      final notes = [_note('1', content: 'long press me')];
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(
        NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          noteViewMode: NoteViewMode.grid,
        ),
      );
      await tester.pump();

      await tester.longPress(find.text('long press me'));
      await tester.pump();

      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      expect(find.text('1 selected'), findsOneWidget);
    });

    testWidgets('bottom bar is hidden in selection mode', (tester) async {
      final notes = [_note('1')];
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(
        NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          selectedIds: const {'1'},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byIcon(Icons.menu), findsNothing);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('AppBar shows correct count when multiple notes are selected', (
      tester,
    ) async {
      final notes = [_note('1'), _note('2'), _note('3')];
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(
        NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          selectedIds: const {'1', '2', '3'},
        ),
      );
      await tester.pump();

      expect(find.text('3 selected'), findsOneWidget);
    });

    testWidgets('close button in selection mode exits selection', (
      tester,
    ) async {
      final notes = [_note('1')];
      final bloc = makeBloc();
      await tester.pumpWidget(buildView(bloc: bloc));

      bloc.emit(
        NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          selectedIds: const {'1'},
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Nota'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    // --- Preferences stream ---

    testWidgets('switches to list view when preferences emit list mode', (
      tester,
    ) async {
      final notes = [_note('1')];
      final bloc = NoteListBloc(
        noteRepository: FakeNoteRepository(notes: notes),
        preferencesService: mockPrefs,
        imageFiles: FakeImageFiles(),
      );
      bloc.add(NoteListStarted());
      await tester.pumpWidget(buildView(bloc: bloc));
      await tester.pumpAndSettle();

      expect(find.byType(SliverMasonryGrid), findsOneWidget);

      prefsController.add(const Preferences(noteViewMode: NoteViewMode.list));
      await tester.pumpAndSettle();

      expect(find.byType(SliverList), findsOneWidget);
    });
  });
}
