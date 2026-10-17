/// How dictated utterances land in the document.
enum DictationMode {
  /// Appended to the current paragraph, separated by spaces.
  text,

  /// Each utterance becomes a list item. A plain paragraph becomes a bullet
  /// list; an existing bullet or numbered list keeps its kind.
  list,

  /// Each utterance becomes an unchecked checklist item.
  checklist;

  /// True for the modes that create one item per utterance.
  bool get isList => this != text;
}
