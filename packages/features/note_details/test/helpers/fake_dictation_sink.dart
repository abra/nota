import 'package:note_details/src/dictation/dictation_mode.dart';
import 'package:note_details/src/dictation/dictation_sink.dart';

class FakeDictationSink implements DictationSink {
  final List<(String text, DictationMode mode)> inserted = [];
  int newLines = 0;
  int undos = 0;
  DictationMode cursorMode = DictationMode.text;

  @override
  void insert(String text, DictationMode mode) => inserted.add((text, mode));

  @override
  void newLine() => newLines++;

  @override
  void undo() => undos++;

  @override
  DictationMode modeAtCursor() => cursorMode;
}
