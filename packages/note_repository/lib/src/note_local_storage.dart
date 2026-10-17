import 'dart:io' show File;

import 'package:drift/drift.dart';
import 'package:drift/native.dart' show NativeDatabase;
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:shared/shared.dart';

import 'mappers/domain_to_storage.dart';
import 'mappers/storage_to_domain.dart';
import 'note_local_storage_exception.dart';

part 'note_local_storage.g.dart';

// ---------------------------------------------------------------------------
// Table definition
// ---------------------------------------------------------------------------

class NotesTable extends Table {
  TextColumn get id => text()();

  TextColumn get title => text().nullable()();

  TextColumn get content => text()();

  TextColumn get createdAt => text()(); // ISO 8601
  TextColumn get updatedAt => text()(); // ISO 8601
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  TextColumn get color => text().withDefault(const Constant('none'))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [NotesTable])
class NoteLocalStorage extends _$NoteLocalStorage {
  NoteLocalStorage() : super(_openConnection());

  @visibleForTesting
  NoteLocalStorage.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // --- queries ---

  Future<List<Note>> allNotes() async {
    try {
      final rows =
          await (select(notesTable)..orderBy([
                (t) => OrderingTerm.desc(t.isPinned),
                (t) => OrderingTerm.desc(t.updatedAt),
              ]))
              .get();
      return rows.map((r) => r.toDomainModel()).toList();
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  Future<Note?> noteById(String id) async {
    try {
      final row = await (select(
        notesTable,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      return row?.toDomainModel();
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  Future<String?> lastCreatedNoteColor() async {
    try {
      return await (select(notesTable)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .map((row) => row.color)
          .getSingleOrNull();
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  Future<void> insertNote(Note note) async {
    try {
      await into(notesTable).insert(note.toStorageModel());
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  /// Inserts [notes], replacing any row that already has the same id, so a
  /// repeated restore of the same notes is harmless.
  Future<void> insertNotes(List<Note> notes) async {
    try {
      await transaction(() async {
        for (final note in notes) {
          await into(notesTable).insertOnConflictUpdate(note.toStorageModel());
        }
      });
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      await (update(
        notesTable,
      )..where((t) => t.id.equals(note.id))).write(note.toStorageModel());
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await (delete(notesTable)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  Future<void> deleteNotes(List<String> ids) async {
    try {
      await transaction(() async {
        for (final id in ids) {
          await (delete(notesTable)..where((t) => t.id.equals(id))).go();
        }
      });
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  Future<void> updateNotes(List<Note> notes) async {
    try {
      await transaction(() async {
        for (final note in notes) {
          await (update(
            notesTable,
          )..where((t) => t.id.equals(note.id))).write(note.toStorageModel());
        }
      });
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }

  Future<bool> isImagePathReferenced(String path) async {
    try {
      final count = countAll();
      final query = selectOnly(notesTable)
        ..addColumns([count])
        ..where(notesTable.content.like('%$path%'));
      final result = await query.getSingle();
      return (result.read(count) ?? 0) > 0;
    } catch (e) {
      throw NoteLocalStorageException(cause: e);
    }
  }
}

// ---------------------------------------------------------------------------
// Connection
// ---------------------------------------------------------------------------

LazyDatabase _openConnection() => LazyDatabase(() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File(p.join(dir.path, 'nota.db'));
  return NativeDatabase.createInBackground(file);
});
