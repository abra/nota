// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class PreferencesLocalizationsZh extends PreferencesLocalizations {
  PreferencesLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get preferences => '首选项';

  @override
  String get theme => '主题';

  @override
  String get notesView => '笔记视图';

  @override
  String get listDensity => '列表密度';

  @override
  String get language => '语言';

  @override
  String get searchHint => '搜索';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get viewGrid => '网格';

  @override
  String get viewList => '列表';

  @override
  String linesCount(int count) {
    return '$count 行';
  }
}
