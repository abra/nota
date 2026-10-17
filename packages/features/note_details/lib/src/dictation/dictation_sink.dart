import 'dictation_mode.dart';

/// Where dictated text goes.
///
/// Implemented by [QuillDictationSink] for the editor and faked in tests so
/// the dictation logic can be exercised without a document.
abstract interface class DictationSink {
  /// Inserts one finished utterance according to [mode].
  void insert(String text, DictationMode mode);

  /// Starts a new line at the cursor, as the toolbar's return button does.
  void newLine();

  /// Reverts the most recent edit (dictated or typed).
  void undo();

  /// The mode that matches the line under the cursor, so dictation continues
  /// whatever structure the user was already writing.
  DictationMode modeAtCursor();
}
