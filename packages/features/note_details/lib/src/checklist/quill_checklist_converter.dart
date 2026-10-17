import 'package:flutter/widgets.dart' show TextSelection;
import 'package:flutter_quill/flutter_quill.dart';

import 'checklist_splitter.dart';

/// Turns the paragraph under the cursor into unchecked checklist items.
///
/// The paragraph's text is split with [splitIntoChecklistItems]; each item
/// becomes its own line carrying the checklist attribute. Inline styles of
/// the original paragraph are dropped (dictated text has none). Returns
/// false when there is nothing to convert: an empty line or one holding an
/// embed.
bool convertParagraphToChecklist(
  QuillController controller, {
  required String languageCode,
}) {
  final document = controller.document;
  final last = document.length - 1;
  final selection = controller.selection;
  final index = selection.isValid ? selection.end.clamp(0, last) : last;
  final node = document.queryChild(index).node;
  if (node is! Line || node.hasEmbed) return false;

  final text = node.toPlainText();
  final body = text.substring(0, text.length - 1); // drop the newline
  final items = splitIntoChecklistItems(body, languageCode: languageCode);
  if (items.isEmpty) return false;

  final start = node.documentOffset;
  final replacement = items.join('\n');
  controller.replaceText(
    start,
    body.length,
    replacement,
    TextSelection.collapsed(offset: start + replacement.length),
  );
  // Line formats apply to every newline in the range and the one after it,
  // so one call marks all the new lines.
  controller.formatText(start, replacement.length, Attribute.unchecked);
  return true;
}
