// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class NoteDetailsLocalizationsAr extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get newNote => 'ملاحظة جديدة';

  @override
  String get editNote => 'تعديل الملاحظة';

  @override
  String get titleHint => 'العنوان';

  @override
  String get contentHint => 'ابدأ الكتابة...';

  @override
  String get noteNotFound => 'الملاحظة غير موجودة';

  @override
  String get noteLoadFailed => 'فشل تحميل الملاحظة';

  @override
  String get noteSaveFailed => 'فشل حفظ الملاحظة';

  @override
  String get noteColor => 'لون الملاحظة';

  @override
  String get imageInsertFailed => 'فشل إدراج الصورة';

  @override
  String get deleteNote => 'حذف الملاحظة';

  @override
  String get pinNote => 'تثبيت';

  @override
  String get unpinNote => 'إزالة التثبيت';

  @override
  String editedAt(String date) {
    return 'تم التعديل $date';
  }

  @override
  String get back => 'رجوع';

  @override
  String get moreActions => 'المزيد';

  @override
  String get formatting => 'التنسيق';

  @override
  String get insertImage => 'إدراج صورة';

  @override
  String get undo => 'تراجع';

  @override
  String get redo => 'إعادة';

  @override
  String get newLine => 'سطر جديد';

  @override
  String get dictate => 'إملاء';

  @override
  String get dictationModeText => 'نص';

  @override
  String get dictationModeList => 'قائمة';

  @override
  String get dictationModeChecklist => 'قائمة مهام';

  @override
  String get dictationStarting => 'جارٍ البدء…';

  @override
  String get dictationListening => 'جارٍ الاستماع…';

  @override
  String get dictationPaused => 'متوقف مؤقتًا. انقر على الميكروفون للمتابعة';

  @override
  String get dictationHintList => 'جارٍ الاستماع… توقف قليلًا بين العناصر';

  @override
  String dictationHintNewLine(String phrase) {
    return 'جارٍ الاستماع… قل «$phrase» لبدء سطر جديد';
  }

  @override
  String get dictationPause => 'إيقاف الإملاء مؤقتًا';

  @override
  String get dictationResume => 'استئناف الإملاء';

  @override
  String get dictationPermissionDenied =>
      'اسمح بالوصول إلى الميكروفون والتعرف على الكلام في الإعدادات';

  @override
  String get dictationUnavailable =>
      'التعرف على الكلام غير متاح على هذا الجهاز';

  @override
  String get dictationLanguageUnsupported =>
      'التعرف على الكلام غير متاح لهذه اللغة';

  @override
  String get dictationNetworkError =>
      'يحتاج التعرف على الكلام إلى اتصال بالشبكة';

  @override
  String get dictationFailed => 'توقف الإملاء بسبب خطأ';

  @override
  String get openSettings => 'الإعدادات';

  @override
  String get dictateNote => 'إملاء ملاحظة';
}
