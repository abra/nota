part of 'note_list_bloc.dart';

sealed class NoteListEvent {}

class NoteListStarted extends NoteListEvent {
  @override
  String toString() => 'NoteListStarted()';
}

class NoteListNoteDeleted extends NoteListEvent {
  NoteListNoteDeleted(this.id);

  final String id;

  @override
  String toString() => 'NoteListNoteDeleted(id: $id)';
}

class NoteListQueryChanged extends NoteListEvent {
  NoteListQueryChanged(this.query);

  final String query;

  @override
  String toString() => 'NoteListQueryChanged(query: "$query")';
}

class NoteListSelectionToggled extends NoteListEvent {
  NoteListSelectionToggled(this.id);

  final String id;

  @override
  String toString() => 'NoteListSelectionToggled(id: $id)';
}

class NoteListSelectionCleared extends NoteListEvent {
  @override
  String toString() => 'NoteListSelectionCleared()';
}

class NoteListSelectedDeleted extends NoteListEvent {
  @override
  String toString() => 'NoteListSelectedDeleted()';
}

class NoteListSelectedPinToggled extends NoteListEvent {
  @override
  String toString() => 'NoteListSelectedPinToggled()';
}

/// Restores the notes removed by the most recent delete operation.
class NoteListUndoDeleteRequested extends NoteListEvent {
  @override
  String toString() => 'NoteListUndoDeleteRequested()';
}

class NoteListNoteUpdated extends NoteListEvent {
  NoteListNoteUpdated(this.note);

  final Note note;

  @override
  String toString() => 'NoteListNoteUpdated(id: ${note.id})';
}

class NoteListNoteAdded extends NoteListEvent {
  NoteListNoteAdded(this.note);

  final Note note;

  @override
  String toString() => 'NoteListNoteAdded(id: ${note.id})';
}

class NoteListNoteRemoved extends NoteListEvent {
  NoteListNoteRemoved(this.id);

  final String id;

  @override
  String toString() => 'NoteListNoteRemoved(id: $id)';
}
