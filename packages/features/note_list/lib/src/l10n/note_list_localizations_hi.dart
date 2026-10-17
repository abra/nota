// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_list_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class NoteListLocalizationsHi extends NoteListLocalizations {
  NoteListLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String selected(int count) {
    return '$count चुने गए';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नोट हटाए गए',
      one: 'नोट हटाया गया',
    );
    return '$_temp0';
  }

  @override
  String get emptyState => 'अभी कोई नोट नहीं';

  @override
  String get searchHint => 'खोजें';

  @override
  String get noteDeleteFailed => 'नोट हटाने में विफल';

  @override
  String get noteUpdateFailed => 'नोट अपडेट करने में विफल';

  @override
  String get loadFailed => 'नोट्स लोड नहीं हो सके';

  @override
  String get retry => 'पुनः प्रयास';

  @override
  String get pinned => 'पिन की गई';

  @override
  String get others => 'अन्य';

  @override
  String get yesterday => 'कल';

  @override
  String get noResults => 'कुछ नहीं मिला';

  @override
  String get noResultsHint => 'कोई दूसरा शब्द खोजें';

  @override
  String get emptyStateHint => 'अपना पहला नोट बनाने के लिए + दबाएँ';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get addNote => 'नया नोट';

  @override
  String get menu => 'मेनू';

  @override
  String get pin => 'पिन करें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get noteRestoreFailed => 'नोट पुनर्स्थापित नहीं हो सका';
}
