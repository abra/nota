// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'note_details_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class NoteDetailsLocalizationsEn extends NoteDetailsLocalizations {
  NoteDetailsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get newNote => 'New note';

  @override
  String get editNote => 'Edit note';

  @override
  String get titleHint => 'Title';

  @override
  String get contentHint => 'Start typing...';

  @override
  String get noteNotFound => 'Note not found';

  @override
  String get noteLoadFailed => 'Failed to load note';

  @override
  String get noteSaveFailed => 'Failed to save note';

  @override
  String get noteColor => 'Note color';

  @override
  String get imageInsertFailed => 'Failed to insert image';

  @override
  String get deleteNote => 'Delete note';

  @override
  String get pinNote => 'Pin';

  @override
  String get unpinNote => 'Unpin';

  @override
  String editedAt(String date) {
    return 'Edited $date';
  }

  @override
  String get back => 'Back';

  @override
  String get moreActions => 'More';

  @override
  String get formatting => 'Formatting';

  @override
  String get insertImage => 'Insert image';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get newLine => 'New line';

  @override
  String get dictate => 'Dictate';

  @override
  String get dictationModeText => 'Text';

  @override
  String get dictationModeList => 'List';

  @override
  String get dictationModeChecklist => 'Checklist';

  @override
  String get dictationStarting => 'Starting…';

  @override
  String get dictationListening => 'Listening…';

  @override
  String get dictationPaused => 'Paused. Tap the microphone to continue';

  @override
  String get dictationHintList => 'Listening… pause between items';

  @override
  String dictationHintNewLine(String phrase) {
    return 'Listening… say “$phrase” for a new line';
  }

  @override
  String get dictationPause => 'Pause dictation';

  @override
  String get dictationResume => 'Resume dictation';

  @override
  String get dictationPermissionDenied =>
      'Allow microphone and speech recognition access in Settings';

  @override
  String get dictationUnavailable =>
      'Speech recognition is not available on this device';

  @override
  String get dictationLanguageUnsupported =>
      'Speech recognition is not available for this language';

  @override
  String get dictationNetworkError =>
      'Speech recognition needs a network connection';

  @override
  String get dictationFailed => 'Dictation stopped because of an error';

  @override
  String get openSettings => 'Settings';

  @override
  String get dictateNote => 'Dictate a note';

  @override
  String get convertToChecklist => 'Paragraph to checklist';

  @override
  String get dictationLanguage => 'Dictation language';

  @override
  String get dictationLanguagesRecent => 'Recent';

  @override
  String get dictationLanguagesAll => 'All languages';

  @override
  String get dictationLanguagesUnavailable =>
      'Speech recognition did not list its languages. Check microphone and speech recognition access.';
}
