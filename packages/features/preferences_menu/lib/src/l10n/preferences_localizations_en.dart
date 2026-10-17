// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class PreferencesLocalizationsEn extends PreferencesLocalizations {
  PreferencesLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get preferences => 'Preferences';

  @override
  String get theme => 'Theme';

  @override
  String get notesView => 'Notes view';

  @override
  String get listDensity => 'List density';

  @override
  String get language => 'Language';

  @override
  String get searchHint => 'Search';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get viewGrid => 'Grid';

  @override
  String get viewList => 'List';

  @override
  String linesCount(int count) {
    return '$count lines';
  }

  @override
  String get dictationPause => 'Pause between phrases';

  @override
  String get pauseShort => 'Short';

  @override
  String get pauseNormal => 'Normal';

  @override
  String get pauseLong => 'Long';

  @override
  String get voiceCommands => 'Voice commands';
}
