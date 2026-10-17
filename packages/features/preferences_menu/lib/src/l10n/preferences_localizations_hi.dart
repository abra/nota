// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class PreferencesLocalizationsHi extends PreferencesLocalizations {
  PreferencesLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get preferences => 'प्राथमिकताएं';

  @override
  String get theme => 'थीम';

  @override
  String get notesView => 'नोट्स दृश्य';

  @override
  String get listDensity => 'सूची घनत्व';

  @override
  String get language => 'भाषा';

  @override
  String get searchHint => 'खोजें';

  @override
  String version(String version) {
    return 'संस्करण $version';
  }

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'हल्का';

  @override
  String get themeDark => 'गहरा';

  @override
  String get viewGrid => 'ग्रिड';

  @override
  String get viewList => 'सूची';

  @override
  String linesCount(int count) {
    return '$count पंक्तियाँ';
  }

  @override
  String get dictationPause => 'वाक्यांशों के बीच विराम';

  @override
  String get pauseShort => 'छोटा';

  @override
  String get pauseNormal => 'सामान्य';

  @override
  String get pauseLong => 'लंबा';

  @override
  String get voiceCommands => 'वॉइस कमांड';
}
