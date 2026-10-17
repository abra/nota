// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NoteDetailsLocalizationsEn extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get newNote => 'New note';

  @override
  String get editNote => 'Edit note';

  @override
  String get titleHint => 'Title';

  @override
  String get contentHint => 'Start typing...';

  @override
  String get noteNotFound => 'Note not found';

  @override
  String get noteLoadFailed => 'Failed to load note';

  @override
  String get noteSaveFailed => 'Failed to save note';

  @override
  String get noteColor => 'Note color';

  @override
  String get imageInsertFailed => 'Failed to insert image';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get pinNote => 'Pin';

  @override
  String get unpinNote => 'Unpin';

  @override
  String editedAt(String date) {
    return 'Edited $date';
  }

  @override
  String get back => 'Back';

  @override
  String get moreActions => 'More';

  @override
  String get formatting => 'Formatting';

  @override
  String get insertImage => 'Insert image';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get newLine => 'New line';
}
