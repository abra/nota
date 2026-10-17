// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class NoteListLocalizationsDe extends NoteListLocalizations {
  NoteListLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String selected(int count) {
    return '$count ausgewählt';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Notizen gelöscht',
      one: 'Notiz gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'Keine Notizen';

  @override
  String get searchHint => 'Suchen';

  @override
  String get noteDeleteFailed => 'Notiz konnte nicht gelöscht werden';

  @override
  String get noteUpdateFailed => 'Notiz konnte nicht aktualisiert werden';

  @override
  String get loadFailed => 'Notizen konnten nicht geladen werden';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get pinned => 'Angeheftet';

  @override
  String get others => 'Andere';

  @override
  String get yesterday => 'Gestern';

  @override
  String get noResults => 'Nichts gefunden';

  @override
  String get noResultsHint => 'Versuche einen anderen Suchbegriff';

  @override
  String get emptyStateHint => 'Tippe auf +, um deine erste Notiz zu erstellen';

  @override
  String get undo => 'Rückgängig';

  @override
  String get addNote => 'Neue Notiz';

  @override
  String get menu => 'Menü';

  @override
  String get pin => 'Anheften';

  @override
  String get delete => 'Löschen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get noteRestoreFailed => 'Notiz konnte nicht wiederhergestellt werden';
}
