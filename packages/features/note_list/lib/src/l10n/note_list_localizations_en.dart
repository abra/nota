// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NoteListLocalizationsEn extends NoteListLocalizations {
  NoteListLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String selected(int count) {
    return '$count selected';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes deleted',
      one: 'Note deleted',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'No notes yet';

  @override
  String get searchHint => 'Search';

  @override
  String get noteDeleteFailed => 'Failed to delete note';

  @override
  String get noteUpdateFailed => 'Failed to update note';

  @override
  String get loadFailed => 'Failed to load notes';

  @override
  String get retry => 'Retry';

  @override
  String get pinned => 'Pinned';

  @override
  String get others => 'Others';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get noResults => 'Nothing found';

  @override
  String get noResultsHint => 'Try a different search term';

  @override
  String get emptyStateHint => 'Tap + to create your first note';

  @override
  String get undo => 'Undo';

  @override
  String get addNote => 'New note';

  @override
  String get menu => 'Menu';

  @override
  String get pin => 'Pin';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get noteRestoreFailed => 'Failed to restore note';
}
