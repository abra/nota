// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class PreferencesLocalizationsPt extends PreferencesLocalizations {
  PreferencesLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get preferences => 'Preferências';

  @override
  String get theme => 'Tema';

  @override
  String get notesView => 'Visualização de notas';

  @override
  String get listDensity => 'Densidade da lista';

  @override
  String get language => 'Idioma';

  @override
  String get searchHint => 'Pesquisar';

  @override
  String version(String version) {
    return 'Versão $version';
  }

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get viewGrid => 'Grade';

  @override
  String get viewList => 'Lista';

  @override
  String linesCount(int count) {
    return '$count linhas';
  }

  @override
  String get dictationPause => 'Pausa entre frases';

  @override
  String get pauseShort => 'Curta';

  @override
  String get pauseNormal => 'Normal';

  @override
  String get pauseLong => 'Longa';

  @override
  String get voiceCommands => 'Comandos de voz';
}
