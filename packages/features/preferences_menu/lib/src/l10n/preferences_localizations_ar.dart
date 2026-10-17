// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class PreferencesLocalizationsAr extends PreferencesLocalizations {
  PreferencesLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get preferences => 'التفضيلات';

  @override
  String get theme => 'المظهر';

  @override
  String get notesView => 'عرض الملاحظات';

  @override
  String get listDensity => 'كثافة القائمة';

  @override
  String get language => 'اللغة';

  @override
  String get searchHint => 'بحث';

  @override
  String version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get themeSystem => 'النظام';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get viewGrid => 'شبكة';

  @override
  String get viewList => 'قائمة';

  @override
  String linesCount(int count) {
    return '$count أسطر';
  }

  @override
  String get dictationPause => 'التوقف بين العبارات';

  @override
  String get pauseShort => 'قصير';

  @override
  String get pauseNormal => 'عادي';

  @override
  String get pauseLong => 'طويل';

  @override
  String get voiceCommands => 'الأوامر الصوتية';
}
