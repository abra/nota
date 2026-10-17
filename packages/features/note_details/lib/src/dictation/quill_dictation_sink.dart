import 'package:flutter/widgets.dart' show TextSelection, ValueGetter;
import 'package:flutter_quill/flutter_quill.dart';

import 'dictation_mode.dart';
import 'dictation_sink.dart';

/// [DictationSink] that writes into a [QuillController].
///
/// The controller is read through [controllerOf] on every call because the
/// editor swaps its controller once the note has loaded.
///
/// Every edit goes through the controller (not the document) so it lands in
/// the undo history and on the `changes` stream that persists the note.
class QuillDictationSink implements DictationSink {
  QuillDictationSink(this.controllerOf);

  final ValueGetter<QuillController> controllerOf;

  @override
  void insert(String text, DictationMode mode) {
    if (text.isEmpty) return;
    final controller = controllerOf();
    final index = _cursorIndex(controller);
    if (mode.isList) {
      _insertListItem(controller, index, text, mode);
    } else {
      _insertInline(controller, index, text);
    }
  }

  @override
  void newLine() {
    final controller = controllerOf();
    final index = _cursorIndex(controller);
    controller.replaceText(
      index,
      0,
      '\n',
      TextSelection.collapsed(offset: index + 1),
    );
  }

  @override
  void undo() {
    final controller = controllerOf();
    if (controller.hasUndo) controller.undo();
  }

  @override
  DictationMode modeAtCursor() {
    final controller = controllerOf();
    final line = _lineAt(controller.document, _cursorIndex(controller));
    final value = line.style.attributes[Attribute.list.key]?.value;
    if (value == Attribute.checked.value ||
        value == Attribute.unchecked.value) {
      return DictationMode.checklist;
    }
    if (value == Attribute.ul.value || value == Attribute.ol.value) {
      return DictationMode.list;
    }
    return DictationMode.text;
  }

  /// Appends [text] at the cursor with the spaces a typist would add.
  void _insertInline(QuillController controller, int index, String text) {
    final line = _lineAt(controller.document, index);
    final lineText = line.toPlainText();
    final offsetInLine = index - line.documentOffset;
    final before = offsetInLine > 0 ? lineText[offsetInLine - 1] : '\n';
    final after = offsetInLine < lineText.length
        ? lineText[offsetInLine]
        : '\n';
    final spaceBefore = _isBoundary(before) ? '' : ' ';
    final spaceAfter = _isBoundary(after) ? '' : ' ';
    final data = '$spaceBefore$text$spaceAfter';
    // The cursor lands after the text, before any trailing space, so the
    // next utterance continues the sentence.
    final cursor = index + spaceBefore.length + text.length;
    controller.replaceText(
      index,
      0,
      data,
      TextSelection.collapsed(offset: cursor),
    );
  }

  /// Makes [text] a list item: on the current line if it is empty, otherwise
  /// on a new line below it.
  void _insertListItem(
    QuillController controller,
    int index,
    String text,
    DictationMode mode,
  ) {
    final document = controller.document;
    var line = _lineAt(document, index);
    var insertAt = line.documentOffset;
    if (line.length > 1) {
      // Splitting at the end of a line keeps the block style on both halves,
      // so a checklist stays a checklist (see Quill's newline insert rules).
      final lineEnd = line.documentOffset + line.length - 1;
      controller.replaceText(
        lineEnd,
        0,
        '\n',
        TextSelection.collapsed(offset: lineEnd + 1),
      );
      insertAt = lineEnd + 1;
      line = _lineAt(document, insertAt);
    }
    controller.replaceText(
      insertAt,
      0,
      text,
      TextSelection.collapsed(offset: insertAt + text.length),
    );
    final attribute = _listAttributeFor(
      mode,
      current: line.style.attributes[Attribute.list.key],
    );
    if (attribute != null) {
      controller.formatText(insertAt, text.length, attribute);
    }
  }

  /// The list attribute to apply, or `null` when the line already has one
  /// that fits [mode].
  static Attribute? _listAttributeFor(
    DictationMode mode, {
    required Attribute? current,
  }) {
    final value = current?.value;
    switch (mode) {
      case DictationMode.checklist:
        return value == Attribute.unchecked.value ? null : Attribute.unchecked;
      case DictationMode.list:
        // Keep a numbered list numbered; only plain paragraphs and
        // checklists turn into bullets.
        if (value == Attribute.ul.value || value == Attribute.ol.value) {
          return null;
        }
        return Attribute.ul;
      case DictationMode.text:
        return null;
    }
  }

  static bool _isBoundary(String char) => char.trim().isEmpty;

  /// The cursor position clamped to the document, or its end when the
  /// selection is invalid. A range selection resolves to its end.
  static int _cursorIndex(QuillController controller) {
    final last = controller.document.length - 1;
    final selection = controller.selection;
    if (!selection.isValid) return last;
    return selection.end.clamp(0, last);
  }

  static Line _lineAt(Document document, int index) {
    final node = document.queryChild(index).node;
    if (node is Line) return node;
    // Out of range: the last line always exists.
    return document.queryChild(document.length - 1).node! as Line;
  }
}
