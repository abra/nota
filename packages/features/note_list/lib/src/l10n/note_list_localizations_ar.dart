// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class NoteListLocalizationsAr extends NoteListLocalizations {
  NoteListLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String selected(int count) {
    return '$count محدد';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تم حذف $count ملاحظات',
      one: 'تم حذف الملاحظة',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'لا توجد ملاحظات';

  @override
  String get searchHint => 'بحث';

  @override
  String get noteDeleteFailed => 'فشل حذف الملاحظة';

  @override
  String get noteUpdateFailed => 'فشل تحديث الملاحظة';

  @override
  String get loadFailed => 'فشل تحميل الملاحظات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get pinned => 'مثبتة';

  @override
  String get others => 'أخرى';

  @override
  String get yesterday => 'أمس';

  @override
  String get noResults => 'لم يتم العثور على شيء';

  @override
  String get noResultsHint => 'جرّب كلمة بحث أخرى';

  @override
  String get emptyStateHint => 'اضغط + لإنشاء أول ملاحظة';

  @override
  String get undo => 'تراجع';

  @override
  String get addNote => 'ملاحظة جديدة';

  @override
  String get menu => 'القائمة';

  @override
  String get pin => 'تثبيت';

  @override
  String get delete => 'حذف';

  @override
  String get cancel => 'إلغاء';

  @override
  String get noteRestoreFailed => 'تعذّر استعادة الملاحظة';
}
