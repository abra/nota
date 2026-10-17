// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class NoteListLocalizationsJa extends NoteListLocalizations {
  NoteListLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String selected(int count) {
    return '$count 件選択中';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のメモを削除しました',
      one: 'メモを削除しました',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'メモがありません';

  @override
  String get searchHint => '検索';

  @override
  String get noteDeleteFailed => 'メモの削除に失敗しました';

  @override
  String get noteUpdateFailed => 'メモの更新に失敗しました';

  @override
  String get loadFailed => 'メモの読み込みに失敗しました';

  @override
  String get retry => '再試行';

  @override
  String get pinned => 'ピン留め';

  @override
  String get others => 'その他';

  @override
  String get yesterday => '昨日';

  @override
  String get noResults => '見つかりませんでした';

  @override
  String get noResultsHint => '別のキーワードで検索してください';

  @override
  String get emptyStateHint => '+ をタップして最初のメモを作成';

  @override
  String get undo => '元に戻す';

  @override
  String get addNote => '新しいメモ';

  @override
  String get menu => 'メニュー';

  @override
  String get pin => 'ピン留め';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get noteRestoreFailed => 'メモを復元できませんでした';
}
