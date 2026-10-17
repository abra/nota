import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart' show Uuid;

import 'note_local_storage.dart';
import 'note_local_storage_exception.dart';

const _uuid = Uuid();

/// SQLite-backed note repository.
class NoteRepository {
  NoteRepository({@visibleForTesting NoteLocalStorage? localStorage})
    : _storage = localStorage ?? NoteLocalStorage();

  final NoteLocalStorage _storage;

  Future<List<Note>> getNotes() async {
    try {
      return await _storage.allNotes();
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  Future<Note?> getNoteById(String id) async {
    try {
      return await _storage.noteById(id);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  Future<Note> createNote({
    String? title,
    required String content,
    NoteColor color = NoteColor.none,
    bool isPinned = false,
  }) async {
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      isPinned: isPinned,
      color: color,
    );
    try {
      await _storage.insertNote(note);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
    return note;
  }

  /// Re-inserts a previously deleted [note] with its original id and
  /// timestamps. Used by "undo" after a delete.
  Future<void> restoreNote(Note note) async {
    try {
      await _storage.insertNote(note);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  /// Re-inserts several previously deleted [notes] in one transaction.
  Future<void> restoreNotes(List<Note> notes) async {
    try {
      await _storage.insertNotes(notes);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  Future<Note> updateNote(Note note) async {
    final updated = note.copyWith(updatedAt: DateTime.now());
    try {
      await _storage.updateNote(updated);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
    return updated;
  }

  Future<void> deleteNote(String id) async {
    try {
      await _storage.deleteNote(id);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  Future<void> deleteNotes(List<String> ids) async {
    try {
      await _storage.deleteNotes(ids);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  Future<List<Note>> updateNotes(List<Note> notes) async {
    final now = DateTime.now();
    final updated = notes.map((n) => n.copyWith(updatedAt: now)).toList();
    try {
      await _storage.updateNotes(updated);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
    return updated;
  }

  Future<bool> isImageReferenced(String imagePath) async {
    try {
      return await _storage.isImagePathReferenced(imagePath);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }

  Future<NoteColor?> getLastCreatedNoteColor() async {
    try {
      final raw = await _storage.lastCreatedNoteColor();
      if (raw == null) return null;
      return NoteColor.from(raw);
    } on NoteLocalStorageException catch (e) {
      throw NoteStorageException(cause: e.cause);
    }
  }
}
