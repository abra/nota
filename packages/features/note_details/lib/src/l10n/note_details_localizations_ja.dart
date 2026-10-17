// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class NoteDetailsLocalizationsJa extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get newNote => '新しいメモ';

  @override
  String get editNote => 'メモを編集';

  @override
  String get titleHint => 'タイトル';

  @override
  String get contentHint => '入力を開始...';

  @override
  String get noteNotFound => 'メモが見つかりません';

  @override
  String get noteLoadFailed => 'メモの読み込みに失敗しました';

  @override
  String get noteSaveFailed => 'メモの保存に失敗しました';

  @override
  String get noteColor => 'ノートの色';

  @override
  String get imageInsertFailed => '画像の挿入に失敗しました';

  @override
  String get deleteNote => 'メモを削除';

  @override
  String get pinNote => 'ピン留め';

  @override
  String get unpinNote => 'ピン留めを解除';

  @override
  String editedAt(String date) {
    return '$date に編集';
  }

  @override
  String get back => '戻る';

  @override
  String get moreActions => 'その他';

  @override
  String get formatting => '書式';

  @override
  String get insertImage => '画像を挿入';

  @override
  String get undo => '元に戻す';

  @override
  String get redo => 'やり直す';

  @override
  String get newLine => '改行';

  @override
  String get dictate => '音声入力';

  @override
  String get dictationModeText => 'テキスト';

  @override
  String get dictationModeList => 'リスト';

  @override
  String get dictationModeChecklist => 'チェックリスト';

  @override
  String get dictationStarting => '開始しています…';

  @override
  String get dictationListening => '聞き取り中…';

  @override
  String get dictationPaused => '一時停止中。マイクをタップして再開';

  @override
  String get dictationHintList => '聞き取り中… 項目の間で少し間を置いてください';

  @override
  String dictationHintNewLine(String phrase) {
    return '聞き取り中… 「$phrase」と言うと改行します';
  }

  @override
  String get dictationPause => '音声入力を一時停止';

  @override
  String get dictationResume => '音声入力を再開';

  @override
  String get dictationPermissionDenied => '設定でマイクと音声認識へのアクセスを許可してください';

  @override
  String get dictationUnavailable => 'このデバイスでは音声認識を利用できません';

  @override
  String get dictationLanguageUnsupported => 'この言語では音声認識を利用できません';

  @override
  String get dictationNetworkError => '音声認識にはネットワーク接続が必要です';

  @override
  String get dictationFailed => 'エラーのため音声入力を停止しました';

  @override
  String get openSettings => '設定';

  @override
  String get dictateNote => '音声でメモ';

  @override
  String get convertToChecklist => '段落をチェックリストに';
}
