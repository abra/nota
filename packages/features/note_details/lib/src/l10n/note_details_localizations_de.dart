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

  @override
  String get dictate => 'Diktieren';

  @override
  String get dictationModeText => 'Text';

  @override
  String get dictationModeList => 'Liste';

  @override
  String get dictationModeChecklist => 'Checkliste';

  @override
  String get dictationStarting => 'Wird gestartet…';

  @override
  String get dictationListening => 'Ich höre zu…';

  @override
  String get dictationPaused =>
      'Pausiert. Tippen Sie auf das Mikrofon, um fortzufahren';

  @override
  String get dictationHintList =>
      'Ich höre zu… machen Sie zwischen den Einträgen eine Pause';

  @override
  String dictationHintNewLine(String phrase) {
    return 'Ich höre zu… sagen Sie „$phrase“ für eine neue Zeile';
  }

  @override
  String get dictationPause => 'Diktat pausieren';

  @override
  String get dictationResume => 'Diktat fortsetzen';

  @override
  String get dictationPermissionDenied =>
      'Erlauben Sie den Zugriff auf Mikrofon und Spracherkennung in den Einstellungen';

  @override
  String get dictationUnavailable =>
      'Spracherkennung ist auf diesem Gerät nicht verfügbar';

  @override
  String get dictationLanguageUnsupported =>
      'Spracherkennung ist für diese Sprache nicht verfügbar';

  @override
  String get dictationNetworkError =>
      'Die Spracherkennung benötigt eine Netzwerkverbindung';

  @override
  String get dictationFailed => 'Das Diktat wurde wegen eines Fehlers beendet';

  @override
  String get openSettings => 'Einstellungen';

  @override
  String get dictateNote => 'Notiz diktieren';
}
