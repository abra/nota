// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class PreferencesLocalizationsEs extends PreferencesLocalizations {
  PreferencesLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get preferences => 'Preferencias';

  @override
  String get theme => 'Tema';

  @override
  String get notesView => 'Vista de notas';

  @override
  String get listDensity => 'Densidad de lista';

  @override
  String get language => 'Idioma';

  @override
  String get searchHint => 'Buscar';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Clara';

  @override
  String get themeDark => 'Oscura';

  @override
  String get viewGrid => 'Cuadrícula';

  @override
  String get viewList => 'Lista';

  @override
  String linesCount(int count) {
    return '$count líneas';
  }
}
