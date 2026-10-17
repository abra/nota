// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class NoteListLocalizationsZh extends NoteListLocalizations {
  NoteListLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String selected(int count) {
    return '$count 已选';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已删除 $count 条笔记',
      one: '已删除笔记',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => '暂无笔记';

  @override
  String get searchHint => '搜索';

  @override
  String get noteDeleteFailed => '删除笔记失败';

  @override
  String get noteUpdateFailed => '更新笔记失败';

  @override
  String get loadFailed => '加载笔记失败';

  @override
  String get retry => '重试';

  @override
  String get pinned => '已置顶';

  @override
  String get others => '其他';

  @override
  String get yesterday => '昨天';

  @override
  String get noResults => '未找到任何内容';

  @override
  String get noResultsHint => '请尝试其他搜索词';

  @override
  String get emptyStateHint => '点按 + 创建第一条笔记';

  @override
  String get undo => '撤销';

  @override
  String get addNote => '新建笔记';

  @override
  String get menu => '菜单';

  @override
  String get pin => '置顶';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get noteRestoreFailed => '无法恢复笔记';
}
