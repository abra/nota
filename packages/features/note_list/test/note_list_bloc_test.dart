import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:note_list/src/note_list_bloc.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart';

import 'helpers/fake_image_files.dart';
import 'helpers/fake_note_repository.dart';

class _MockPreferencesService extends Mock implements PreferencesService {}

Note _note(
  String id, {
  String? title,
  String content = 'body',
  bool isPinned = false,
  DateTime? createdAt,
  DateTime? updatedAt,
}) => Note(
  id: id,
  title: title,
  content: content,
  isPinned: isPinned,
  createdAt: createdAt ?? DateTime(2024),
  updatedAt: updatedAt ?? DateTime(2024),
);

void main() {
  group('NoteListBloc', () {
    late FakeNoteRepository repo;
    late _MockPreferencesService mockPrefs;
    late StreamController<Preferences> prefsController;

    late FakeImageFiles imageFiles;

    setUp(() {
      imageFiles = FakeImageFiles();
      repo = FakeNoteRepository();
      mockPrefs = _MockPreferencesService();
      prefsController = StreamController<Preferences>.broadcast();
      when(() => mockPrefs.current).thenReturn(const Preferences());
      when(() => mockPrefs.stream).thenAnswer((_) => prefsController.stream);
    });

    tearDown(() => prefsController.close());

    test('initial state', () {
      final bloc = NoteListBloc(
        noteRepository: repo,
        preferencesService: mockPrefs,
        imageFiles: FakeImageFiles(),
      );
      expect(bloc.state, const NoteListState());
    });

    group('NoteListStarted', () {
      final notes = [_note('1'), _note('2')];

      blocTest<NoteListBloc, NoteListState>(
        'emits loading then success with notes',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: notes),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        act: (bloc) => bloc.add(NoteListStarted()),
        expect: () => [
          const NoteListState(status: NoteListStatus.loading),
          NoteListState(status: NoteListStatus.success, notes: notes),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits loading then failure on exception',
        build: () {
          final r = FakeNoteRepository()..shouldThrow = true;
          return NoteListBloc(
            noteRepository: r,
            preferencesService: mockPrefs,
            imageFiles: FakeImageFiles(),
          );
        },
        act: (bloc) => bloc.add(NoteListStarted()),
        expect: () => [
          const NoteListState(status: NoteListStatus.loading),
          const NoteListState(status: NoteListStatus.failure),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits success with empty list when no notes',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        act: (bloc) => bloc.add(NoteListStarted()),
        expect: () => [
          const NoteListState(status: NoteListStatus.loading),
          const NoteListState(status: NoteListStatus.success),
        ],
      );
    });

    group('NoteListNoteDeleted', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'removes note from state',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListNoteDeleted('2')),
        expect: () => [
          NoteListState(
            status: NoteListStatus.success,
            notes: [_note('1'), _note('3')],
            lastDeleted: [_note('2')],
          ),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'clears operationFailure on success',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
          operationFailure: (
            error: const NoteStorageException(cause: 'previous error'),
            operation: NoteListFailedOperation.delete,
          ),
        ),
        act: (bloc) => bloc.add(NoteListNoteDeleted('1')),
        verify: (bloc) => expect(bloc.state.operationFailure, isNull),
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits operationFailure when deleteNote throws',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes))
            ..shouldThrow = true,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListNoteDeleted('2')),
        verify: (bloc) {
          expect(bloc.state.operationFailure, isNotNull);
          expect(
            bloc.state.operationFailure!.operation,
            NoteListFailedOperation.delete,
          );
          expect(bloc.state.notes, hasLength(3));
        },
      );

      blocTest<NoteListBloc, NoteListState>(
        'removes note and succeeds even when image cleanup throws (non-fatal)',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles()..shouldThrow = true,
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListNoteDeleted('2')),
        verify: (bloc) {
          expect(bloc.state.operationFailure, isNull);
          expect(bloc.state.notes, hasLength(2));
        },
      );
    });

    group('NoteListSelectedDeleted', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'removes selected notes from state',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
          selectedIds: {'1', '3'},
        ),
        act: (bloc) => bloc.add(NoteListSelectedDeleted()),
        verify: (bloc) {
          expect(bloc.state.notes.map((n) => n.id), ['2']);
          expect(bloc.state.selectedIds, isEmpty);
          expect(bloc.state.operationFailure, isNull);
        },
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits operationFailure when batch delete throws',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes))
            ..shouldThrow = true,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
          selectedIds: {'1', '2'},
        ),
        act: (bloc) => bloc.add(NoteListSelectedDeleted()),
        verify: (bloc) {
          expect(bloc.state.operationFailure, isNotNull);
          expect(
            bloc.state.operationFailure!.operation,
            NoteListFailedOperation.delete,
          );
          expect(bloc.state.notes, hasLength(3));
        },
      );

      blocTest<NoteListBloc, NoteListState>(
        'removes notes and succeeds even when image cleanup throws (non-fatal)',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles()..shouldThrow = true,
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
          selectedIds: {'1', '2'},
        ),
        act: (bloc) => bloc.add(NoteListSelectedDeleted()),
        verify: (bloc) {
          expect(bloc.state.operationFailure, isNull);
          expect(bloc.state.notes.map((n) => n.id), ['3']);
          expect(bloc.state.selectedIds, isEmpty);
        },
      );
    });

    group('NoteListSelectedPinToggled', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'toggles pin for selected notes using batch update',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
          selectedIds: {'1', '3'},
        ),
        act: (bloc) => bloc.add(NoteListSelectedPinToggled()),
        verify: (bloc) {
          final n1 = bloc.state.notes.firstWhere((n) => n.id == '1');
          final n3 = bloc.state.notes.firstWhere((n) => n.id == '3');
          expect(n1.isPinned, isTrue);
          expect(n3.isPinned, isTrue);
          expect(bloc.state.selectedIds, isEmpty);
        },
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits update operationFailure when batch update throws',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes))
            ..shouldThrow = true,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
          selectedIds: {'1'},
        ),
        act: (bloc) => bloc.add(NoteListSelectedPinToggled()),
        verify: (bloc) {
          expect(bloc.state.operationFailure, isNotNull);
          expect(
            bloc.state.operationFailure!.operation,
            NoteListFailedOperation.update,
          );
        },
      );
    });

    group('NoteListNoteUpdated', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'replaces note with matching id',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) =>
            bloc.add(NoteListNoteUpdated(_note('2', content: 'updated'))),
        expect: () => [
          NoteListState(
            status: NoteListStatus.success,
            notes: [
              _note('1'),
              _note('2', content: 'updated'),
              _note('3'),
            ],
          ),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'moves pinned note to top after update',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: [_note('1'), _note('2')],
        ),
        act: (bloc) =>
            bloc.add(NoteListNoteUpdated(_note('2', isPinned: true))),
        verify: (bloc) => expect(bloc.state.notes.first.id, '2'),
      );

      blocTest<NoteListBloc, NoteListState>(
        'sorts by updatedAt when both unpinned',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: [
            _note('1', updatedAt: DateTime(2024, 1, 1)),
            _note('2', updatedAt: DateTime(2024, 1, 2)),
          ],
        ),
        act: (bloc) => bloc.add(
          NoteListNoteUpdated(_note('1', updatedAt: DateTime(2024, 1, 3))),
        ),
        verify: (bloc) => expect(bloc.state.notes.first.id, '1'),
      );
    });

    group('NoteListNoteAdded', () {
      blocTest<NoteListBloc, NoteListState>(
        'adds note to list',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () =>
            NoteListState(status: NoteListStatus.success, notes: [_note('1')]),
        act: (bloc) => bloc.add(NoteListNoteAdded(_note('2'))),
        verify: (bloc) {
          expect(bloc.state.notes, hasLength(2));
          expect(bloc.state.notes.any((n) => n.id == '2'), isTrue);
        },
      );

      blocTest<NoteListBloc, NoteListState>(
        'places pinned note at top',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () =>
            NoteListState(status: NoteListStatus.success, notes: [_note('1')]),
        act: (bloc) => bloc.add(NoteListNoteAdded(_note('2', isPinned: true))),
        verify: (bloc) => expect(bloc.state.notes.first.id, '2'),
      );
    });

    group('NoteListNoteRemoved', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'removes note from list',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListNoteRemoved('2')),
        expect: () => [
          NoteListState(
            status: NoteListStatus.success,
            notes: [_note('1'), _note('3')],
          ),
        ],
      );

      blocTest<NoteListBloc, NoteListState>(
        'ignores unknown id',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListNoteRemoved('999')),
        verify: (bloc) => expect(bloc.state.notes, hasLength(3)),
      );
    });

    group('NoteListQueryChanged', () {
      blocTest<NoteListBloc, NoteListState>(
        'updates query in state',
        build: () => NoteListBloc(
          noteRepository: repo,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        act: (bloc) => bloc.add(NoteListQueryChanged('hello')),
        wait: const Duration(milliseconds: 350),
        expect: () => [const NoteListState(query: 'hello')],
      );
    });

    group('filteredNotes', () {
      final notes = [
        _note('1', title: 'Flutter tips', content: 'Dart stuff'),
        _note('2', title: 'Shopping list', content: 'milk, eggs'),
        _note('3', title: null, content: 'buy groceries'),
      ];

      test('returns all notes when query is empty', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
        );
        expect(state.filteredNotes, notes);
      });

      test('filters by title', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          query: 'flutter',
        );
        expect(state.filteredNotes, [notes[0]]);
      });

      test('filters by content', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          query: 'milk',
        );
        expect(state.filteredNotes, [notes[1]]);
      });

      test('is case insensitive', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          query: 'GROCERIES',
        );
        expect(state.filteredNotes, [notes[2]]);
      });

      test('returns empty list when no match', () {
        final state = NoteListState(
          status: NoteListStatus.success,
          notes: notes,
          query: 'zzz',
        );
        expect(state.filteredNotes, isEmpty);
      });
    });

    group('NoteListUndoDeleteRequested', () {
      final notes = [_note('1'), _note('2'), _note('3')];

      blocTest<NoteListBloc, NoteListState>(
        'restores last deleted notes in sorted position and clears lastDeleted',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: [_note('1'), _note('3')]),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: [_note('1'), _note('3')],
          lastDeleted: [_note('2', updatedAt: DateTime(2025))],
        ),
        act: (bloc) => bloc.add(NoteListUndoDeleteRequested()),
        verify: (bloc) {
          expect(bloc.state.notes.map((n) => n.id), ['2', '1', '3']);
          expect(bloc.state.lastDeleted, isNull);
          expect(bloc.state.operationFailure, isNull);
        },
      );

      blocTest<NoteListBloc, NoteListState>(
        'does nothing when there is nothing to restore',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: List.of(notes)),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: List.of(notes),
        ),
        act: (bloc) => bloc.add(NoteListUndoDeleteRequested()),
        expect: () => <NoteListState>[],
      );

      blocTest<NoteListBloc, NoteListState>(
        'emits restore failure when repository throws',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: [])..shouldThrow = true,
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles(),
        ),
        seed: () => NoteListState(
          status: NoteListStatus.success,
          lastDeleted: [_note('2')],
        ),
        act: (bloc) => bloc.add(NoteListUndoDeleteRequested()),
        verify: (bloc) {
          expect(
            bloc.state.operationFailure?.operation,
            NoteListFailedOperation.restore,
          );
          expect(bloc.state.lastDeleted, isNotNull);
        },
      );
    });

    group('orphan image sweep', () {
      blocTest<NoteListBloc, NoteListState>(
        'passes every referenced image path to deleteUnreferenced on start',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(
            notes: [
              _note(
                '1',
                content:
                    '{"ops":[{"insert":{"image":"/img/a.jpg"}},{"insert":"\\n"}]}',
              ),
              _note(
                '2',
                content:
                    '{"ops":[{"insert":{"image":"/img/b.jpg"}},{"insert":"\\n"}]}',
              ),
            ],
          ),
          preferencesService: mockPrefs,
          imageFiles: imageFiles,
        ),
        act: (bloc) => bloc.add(NoteListStarted()),
        wait: const Duration(milliseconds: 10),
        verify: (_) {
          expect(imageFiles.lastReferencedPaths, {'/img/a.jpg', '/img/b.jpg'});
        },
      );

      blocTest<NoteListBloc, NoteListState>(
        'load still succeeds when the sweep throws',
        build: () => NoteListBloc(
          noteRepository: FakeNoteRepository(notes: [_note('1')]),
          preferencesService: mockPrefs,
          imageFiles: FakeImageFiles()..shouldThrow = true,
        ),
        act: (bloc) => bloc.add(NoteListStarted()),
        wait: const Duration(milliseconds: 10),
        verify: (bloc) {
          expect(bloc.state.status, NoteListStatus.success);
          expect(bloc.state.notes, hasLength(1));
        },
      );
    });

    group('image reference safety', () {
      blocTest<NoteListBloc, NoteListState>(
        'does not delete image still referenced by another note',
        build: () {
          final noteWithImage = _note(
            '1',
            content:
                '{"ops":[{"insert":{"image":"/img/shared.jpg"}},{"insert":"\\n"}]}',
          );
          final otherNoteWithSameImage = _note(
            '2',
            content:
                '{"ops":[{"insert":{"image":"/img/shared.jpg"}},{"insert":"\\n"}]}',
          );
          return NoteListBloc(
            noteRepository: FakeNoteRepository(
              notes: [noteWithImage, otherNoteWithSameImage],
            ),
            preferencesService: mockPrefs,
            imageFiles: FakeImageFiles(),
          );
        },
        seed: () => NoteListState(
          status: NoteListStatus.success,
          notes: [
            _note(
              '1',
              content:
                  '{"ops":[{"insert":{"image":"/img/shared.jpg"}},{"insert":"\\n"}]}',
            ),
            _note(
              '2',
              content:
                  '{"ops":[{"insert":{"image":"/img/shared.jpg"}},{"insert":"\\n"}]}',
            ),
          ],
        ),
        act: (bloc) => bloc.add(NoteListNoteDeleted('1')),
        verify: (bloc) {
          expect(bloc.state.notes, hasLength(1));
          expect(bloc.state.notes.first.id, '2');
        },
      );
    });
  });
}
