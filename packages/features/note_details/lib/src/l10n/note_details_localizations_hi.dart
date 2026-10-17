// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class NoteDetailsLocalizationsHi extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get newNote => 'नई नोट';

  @override
  String get editNote => 'नोट संपादित करें';

  @override
  String get titleHint => 'शीर्षक';

  @override
  String get contentHint => 'टाइप करना शुरू करें...';

  @override
  String get noteNotFound => 'नोट नहीं मिला';

  @override
  String get noteLoadFailed => 'नोट लोड नहीं हो सका';

  @override
  String get noteSaveFailed => 'नोट सहेजा नहीं जा सका';

  @override
  String get noteColor => 'नोट का रंग';

  @override
  String get imageInsertFailed => 'छवि सम्मिलित नहीं हो सकी';

  @override
  String get deleteNote => 'नोट हटाएँ';

  @override
  String get pinNote => 'पिन करें';

  @override
  String get unpinNote => 'अनपिन करें';

  @override
  String editedAt(String date) {
    return '$date को संपादित';
  }

  @override
  String get back => 'वापस';

  @override
  String get moreActions => 'अधिक';

  @override
  String get formatting => 'फ़ॉर्मैटिंग';

  @override
  String get insertImage => 'छवि डालें';

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get redo => 'फिर से करें';

  @override
  String get newLine => 'नई पंक्ति';
}
