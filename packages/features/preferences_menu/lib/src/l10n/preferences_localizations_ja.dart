// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'preferences_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class PreferencesLocalizationsJa extends PreferencesLocalizations {
  PreferencesLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get preferences => '設定';

  @override
  String get theme => 'テーマ';

  @override
  String get notesView => 'ノートの表示';

  @override
  String get listDensity => 'リスト密度';

  @override
  String get language => '言語';

  @override
  String get searchHint => '検索';

  @override
  String version(String version) {
    return 'バージョン $version';
  }

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get viewGrid => 'グリッド';

  @override
  String get viewList => 'リスト';

  @override
  String linesCount(int count) {
    return '$count 行';
  }

  @override
  String get dictationPause => 'フレーズ間の間';

  @override
  String get pauseShort => '短い';

  @override
  String get pauseNormal => '標準';

  @override
  String get pauseLong => '長い';

  @override
  String get voiceCommands => '音声コマンド';

  @override
  String get dictationLanguage => '音声入力の言語';

  @override
  String get dictationLanguageApp => 'アプリと同じ';

  @override
  String get dictationLanguagesRecent => '最近使った言語';

  @override
  String get dictationLanguagesAll => 'すべての言語';

  @override
  String get dictationLanguagesUnavailable =>
      '音声認識から言語の一覧を取得できませんでした。マイクと音声認識へのアクセスを確認してください。';
}
