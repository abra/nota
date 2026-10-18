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

  @override
  String get dictate => 'बोलकर लिखें';

  @override
  String get dictationModeText => 'टेक्स्ट';

  @override
  String get dictationModeList => 'सूची';

  @override
  String get dictationModeChecklist => 'चेकलिस्ट';

  @override
  String get dictationStarting => 'शुरू हो रहा है…';

  @override
  String get dictationListening => 'सुन रहा है…';

  @override
  String get dictationPaused =>
      'रुका हुआ है। जारी रखने के लिए माइक्रोफ़ोन टैप करें';

  @override
  String get dictationHintList => 'सुन रहा है… आइटम के बीच थोड़ा रुकें';

  @override
  String dictationHintNewLine(String phrase) {
    return 'सुन रहा है… नई पंक्ति के लिए “$phrase” कहें';
  }

  @override
  String get dictationPause => 'डिक्टेशन रोकें';

  @override
  String get dictationResume => 'डिक्टेशन जारी रखें';

  @override
  String get dictationPermissionDenied =>
      'सेटिंग्स में माइक्रोफ़ोन और वाक् पहचान की अनुमति दें';

  @override
  String get dictationUnavailable => 'इस डिवाइस पर वाक् पहचान उपलब्ध नहीं है';

  @override
  String get dictationLanguageUnsupported =>
      'इस भाषा के लिए वाक् पहचान उपलब्ध नहीं है';

  @override
  String get dictationNetworkError =>
      'वाक् पहचान के लिए नेटवर्क कनेक्शन आवश्यक है';

  @override
  String get dictationFailed => 'त्रुटि के कारण डिक्टेशन रुक गया';

  @override
  String get openSettings => 'सेटिंग्स';

  @override
  String get dictateNote => 'बोलकर नोट लिखें';

  @override
  String get convertToChecklist => 'अनुच्छेद को चेकलिस्ट में';

  @override
  String get dictationLanguage => 'बोलकर लिखने की भाषा';

  @override
  String get dictationLanguagesRecent => 'हाल में इस्तेमाल';

  @override
  String get dictationLanguagesAll => 'सभी भाषाएँ';

  @override
  String get dictationLanguagesUnavailable =>
      'वाक् पहचान ने भाषाओं की सूची नहीं दी। माइक्रोफ़ोन और वाक् पहचान की अनुमति जाँचें।';
}
