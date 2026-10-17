// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class NoteDetailsLocalizationsDe extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get newNote => 'Neue Notiz';

  @override
  String get editNote => 'Notiz bearbeiten';

  @override
  String get titleHint => 'Titel';

  @override
  String get contentHint => 'Beginne zu tippen...';

  @override
  String get noteNotFound => 'Notiz nicht gefunden';

  @override
  String get noteLoadFailed => 'Notiz konnte nicht geladen werden';

  @override
  String get noteSaveFailed => 'Notiz konnte nicht gespeichert werden';

  @override
  String get noteColor => 'Notizenfarbe';

  @override
  String get imageInsertFailed => 'Bild konnte nicht eingefügt werden';

  @override
  String get deleteNote => 'Notiz löschen';

  @override
  String get pinNote => 'Anheften';

  @override
  String get unpinNote => 'Lösen';

  @override
  String editedAt(String date) {
    return 'Bearbeitet $date';
  }

  @override
  String get back => 'Zurück';

  @override
  String get moreActions => 'Mehr';

  @override
  String get formatting => 'Formatierung';

  @override
  String get insertImage => 'Bild einfügen';

  @override
  String get undo => 'Rückgängig';

  @override
  String get redo => 'Wiederholen';

  @override
  String get newLine => 'Neue Zeile';
}
