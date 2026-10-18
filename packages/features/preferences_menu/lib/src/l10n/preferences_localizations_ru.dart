// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class PreferencesLocalizationsRu extends PreferencesLocalizations {
  PreferencesLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get preferences => 'Настройки';

  @override
  String get theme => 'Тема';

  @override
  String get notesView => 'Вид заметок';

  @override
  String get listDensity => 'Плотность списка';

  @override
  String get language => 'Язык';

  @override
  String get searchHint => 'Поиск';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get viewGrid => 'Сетка';

  @override
  String get viewList => 'Список';

  @override
  String linesCount(int count) {
    return '$count строки';
  }

  @override
  String get dictationPause => 'Пауза между фразами';

  @override
  String get pauseShort => 'Короткая';

  @override
  String get pauseNormal => 'Обычная';

  @override
  String get pauseLong => 'Длинная';

  @override
  String get voiceCommands => 'Голосовые команды';

  @override
  String get dictationLanguage => 'Язык диктовки';

  @override
  String get dictationLanguageApp => 'Как в приложении';

  @override
  String get dictationLanguagesRecent => 'Недавние';

  @override
  String get dictationLanguagesAll => 'Все языки';

  @override
  String get dictationLanguagesUnavailable =>
      'Распознавание речи не сообщило список языков. Проверьте доступ к микрофону и распознаванию речи.';
}
