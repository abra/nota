part of 'note_list_bloc.dart';

enum NoteListStatus { initial, loading, success, failure }

enum NoteListFailedOperation { delete, update, restore }

const Object _kAbsent = Object();

// Lower-cased "title + body" per note, decoded from Delta JSON once and kept
// for the lifetime of the Note instance. Notes are immutable and reused across
// state copies, so an identity-keyed Expando is a safe, self-cleaning cache.
final _searchTextCache = Expando<String>('note search text');

String _searchTextOf(Note note) => _searchTextCache[note] ??=
    '${note.title ?? ''}\n${DeltaUtils.toPlainText(note.content)}'
        .toLowerCase();

class NoteListState extends Equatable {
  const NoteListState({
    this.status = NoteListStatus.initial,
    this.notes = const [],
    this.query = '',
    this.selectedIds = const {},
    this.operationFailure,
    this.lastDeleted,
    this.noteViewMode = NoteViewMode.grid,
    this.noteListDensity = NoteListDensity.threeLines,
  });

  final NoteListStatus status;
  final List<Note> notes;
  final String query;
  final Set<String> selectedIds;
  final ({Object error, NoteListFailedOperation operation})? operationFailure;

  /// Notes removed by the most recent successful delete, kept so the user can
  /// undo. A new list instance is set on every delete so listeners fire once
  /// per operation; cleared when the delete is undone.
  final List<Note>? lastDeleted;

  final NoteViewMode noteViewMode;
  final NoteListDensity noteListDensity;

  bool get isSelectionMode => selectedIds.isNotEmpty;

  bool get hasQuery => query.trim().isNotEmpty;

  /// Notes matching [query] by title or plain-text body; all notes when the
  /// query is blank. Compute once per build and pass the result down.
  List<Note> get filteredNotes {
    if (!hasQuery) return notes;
    final q = query.trim().toLowerCase();
    return notes.where((n) => _searchTextOf(n).contains(q)).toList();
  }

  NoteListState copyWith({
    NoteListStatus? status,
    List<Note>? notes,
    String? query,
    Set<String>? selectedIds,
    Object? operationFailure = _kAbsent,
    Object? lastDeleted = _kAbsent,
    NoteViewMode? noteViewMode,
    NoteListDensity? noteListDensity,
  }) => NoteListState(
    status: status ?? this.status,
    notes: notes ?? this.notes,
    query: query ?? this.query,
    selectedIds: selectedIds ?? this.selectedIds,
    operationFailure: identical(operationFailure, _kAbsent)
        ? this.operationFailure
        : operationFailure
              as ({Object error, NoteListFailedOperation operation})?,
    lastDeleted: identical(lastDeleted, _kAbsent)
        ? this.lastDeleted
        : lastDeleted as List<Note>?,
    noteViewMode: noteViewMode ?? this.noteViewMode,
    noteListDensity: noteListDensity ?? this.noteListDensity,
  );

  @override
  List<Object?> get props => [
    status,
    notes,
    query,
    selectedIds,
    operationFailure,
    lastDeleted,
    noteViewMode,
    noteListDensity,
  ];

  @override
  String toString() =>
      'NoteListState(status: $status, notes: ${notes.length}, '
      'query: "$query", selected: ${selectedIds.length})';
}
