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

  @override
  String get dictate => '语音输入';

  @override
  String get dictationModeText => '文本';

  @override
  String get dictationModeList => '列表';

  @override
  String get dictationModeChecklist => '清单';

  @override
  String get dictationStarting => '正在启动…';

  @override
  String get dictationListening => '正在聆听…';

  @override
  String get dictationPaused => '已暂停。点按麦克风继续';

  @override
  String get dictationHintList => '正在聆听… 条目之间请稍作停顿';

  @override
  String dictationHintNewLine(String phrase) {
    return '正在聆听… 说“$phrase”可换行';
  }

  @override
  String get dictationPause => '暂停语音输入';

  @override
  String get dictationResume => '继续语音输入';

  @override
  String get dictationPermissionDenied => '请在设置中允许访问麦克风和语音识别';

  @override
  String get dictationUnavailable => '此设备不支持语音识别';

  @override
  String get dictationLanguageUnsupported => '此语言不支持语音识别';

  @override
  String get dictationNetworkError => '语音识别需要网络连接';

  @override
  String get dictationFailed => '语音输入因错误而停止';

  @override
  String get openSettings => '设置';

  @override
  String get dictateNote => '语音记笔记';

  @override
  String get convertToChecklist => '段落转为清单';

  @override
  String get dictationLanguage => '语音输入语言';

  @override
  String get dictationLanguagesRecent => '最近使用';

  @override
  String get dictationLanguagesAll => '所有语言';

  @override
  String get dictationLanguagesUnavailable => '语音识别未提供语言列表。请检查麦克风和语音识别权限。';
}
