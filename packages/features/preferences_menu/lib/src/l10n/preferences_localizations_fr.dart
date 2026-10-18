// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class PreferencesLocalizationsFr extends PreferencesLocalizations {
  PreferencesLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get preferences => 'Préférences';

  @override
  String get theme => 'Thème';

  @override
  String get notesView => 'Vue des notes';

  @override
  String get listDensity => 'Densité de liste';

  @override
  String get language => 'Langue';

  @override
  String get searchHint => 'Rechercher';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get viewGrid => 'Grille';

  @override
  String get viewList => 'Liste';

  @override
  String linesCount(int count) {
    return '$count lignes';
  }

  @override
  String get dictationPause => 'Pause entre les phrases';

  @override
  String get pauseShort => 'Courte';

  @override
  String get pauseNormal => 'Normale';

  @override
  String get pauseLong => 'Longue';

  @override
  String get voiceCommands => 'Commandes vocales';

  @override
  String get dictationLanguage => 'Langue de dictée';

  @override
  String get dictationLanguageApp => 'Comme l’app';

  @override
  String get dictationLanguagesRecent => 'Récentes';

  @override
  String get dictationLanguagesAll => 'Toutes les langues';

  @override
  String get dictationLanguagesUnavailable =>
      'La reconnaissance vocale n’a indiqué aucune langue. Vérifiez l’accès au micro et à la reconnaissance vocale.';
}
