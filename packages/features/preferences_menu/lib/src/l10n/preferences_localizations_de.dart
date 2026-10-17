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
}
