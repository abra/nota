// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class NoteDetailsLocalizationsZh extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get newNote => '新建笔记';

  @override
  String get editNote => '编辑笔记';

  @override
  String get titleHint => '标题';

  @override
  String get contentHint => '开始输入...';

  @override
  String get noteNotFound => '笔记未找到';

  @override
  String get noteLoadFailed => '加载笔记失败';

  @override
  String get noteSaveFailed => '保存笔记失败';

  @override
  String get noteColor => '笔记颜色';

  @override
  String get imageInsertFailed => '插入图片失败';

  @override
  String get deleteNote => '删除笔记';

  @override
  String get pinNote => '置顶';

  @override
  String get unpinNote => '取消置顶';

  @override
  String editedAt(String date) {
    return '编辑于 $date';
  }

  @override
  String get back => '返回';

  @override
  String get moreActions => '更多';

  @override
  String get formatting => '格式';

  @override
  String get insertImage => '插入图片';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get newLine => '换行';
}
