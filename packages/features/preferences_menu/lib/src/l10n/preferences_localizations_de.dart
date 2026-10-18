// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class PreferencesLocalizationsDe extends PreferencesLocalizations {
  PreferencesLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get preferences => 'Einstellungen';

  @override
  String get theme => 'Design';

  @override
  String get notesView => 'Notizenansicht';

  @override
  String get listDensity => 'Listendichte';

  @override
  String get language => 'Sprache';

  @override
  String get searchHint => 'Suchen';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get viewGrid => 'Raster';

  @override
  String get viewList => 'Liste';

  @override
  String linesCount(int count) {
    return '$count Zeilen';
  }

  @override
  String get dictationPause => 'Pause zwischen Sätzen';

  @override
  String get pauseShort => 'Kurz';

  @override
  String get pauseNormal => 'Normal';

  @override
  String get pauseLong => 'Lang';

  @override
  String get voiceCommands => 'Sprachbefehle';

  @override
  String get dictationLanguage => 'Diktiersprache';

  @override
  String get dictationLanguageApp => 'Wie in der App';

  @override
  String get dictationLanguagesRecent => 'Zuletzt verwendet';

  @override
  String get dictationLanguagesAll => 'Alle Sprachen';

  @override
  String get dictationLanguagesUnavailable =>
      'Die Spracherkennung hat keine Sprachen gemeldet. Prüfen Sie den Zugriff auf Mikrofon und Spracherkennung.';
}
