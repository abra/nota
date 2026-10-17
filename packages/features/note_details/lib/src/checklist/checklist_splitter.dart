/// Splits dictated or typed prose into checklist items.
///
/// Deterministic on purpose: it runs offline on every device, is testable,
/// and matches how people dictate lists — items separated by pauses that
/// the recogniser turns into commas and full stops ("milk, bread and eggs.
/// Call the dentist"). Rules, in order:
///
/// 1. Each line loses its list marker ("- ", "2. "), then line breaks and
///    sentence or list punctuation separate items.
/// 2. In languages with word spaces, a conjunction ("and", "и", "und", …)
///    separates items too, but only between short phrases, so "rock and
///    roll" in a sentence survives while "bread and butter" in a list
///    splits. Japanese and Chinese rely on punctuation alone; their
///    conjunction characters are too ambiguous.
/// 3. Items are trimmed, stripped of trailing punctuation, and start with a
///    capital letter where the script has one.
List<String> splitIntoChecklistItems(
  String text, {
  required String languageCode,
}) {
  final conjunction = _conjunctionPattern(languageCode.toLowerCase());
  final items = <String>[];
  for (final line in text.split('\n')) {
    final unmarked = line.trimLeft().replaceFirst(_leadingMarker, '');
    for (final piece in unmarked.split(_separators)) {
      for (final part in _splitOnConjunction(piece, conjunction)) {
        final cleaned = _clean(part);
        if (cleaned.isNotEmpty) items.add(cleaned);
      }
    }
  }
  return items;
}

/// Latin, Cyrillic, Devanagari, Arabic and CJK sentence and list separators,
/// plus spaced dashes and bullets used as inline separators.
final _separators = RegExp(r'[;,.!?।؛،。！？；，、]+|\s+[-–—•·]\s+');

/// Items may be at most this many words for a conjunction split to apply.
const _maxConjunctionWords = 3;

const _conjunctions = <String, List<String>>{
  'en': ['and'],
  'ru': ['и'],
  'de': ['und'],
  'es': ['y', 'e'],
  'fr': ['et'],
  'pt': ['e'],
  'hi': ['और'],
};

final _conjunctionPatterns = <String, RegExp>{};

RegExp? _conjunctionPattern(String language) {
  final words = _conjunctions[language];
  if (words == null) return null;
  return _conjunctionPatterns.putIfAbsent(
    language,
    () => RegExp(
      r'\s+(?:' + words.map(RegExp.escape).join('|') + r')\s+',
      caseSensitive: false,
    ),
  );
}

Iterable<String> _splitOnConjunction(String piece, RegExp? conjunction) {
  if (conjunction == null || piece.trim().isEmpty) return [piece];
  final parts = piece.split(conjunction);
  if (parts.length < 2) return [piece];
  final short = parts.every(
    (part) => part.trim().split(_whitespace).length <= _maxConjunctionWords,
  );
  return short ? parts : [piece];
}

final _whitespace = RegExp(r'\s+');
final _leadingMarker = RegExp(r'^(?:[-–—•*]|\d+[.)])\s+');
final _trailingPunctuation = RegExp(r'[\s\p{P}]+$', unicode: true);

String _clean(String part) {
  final item = part.trim().replaceAll(_trailingPunctuation, '').trim();
  if (item.isEmpty) return '';
  return item.substring(0, 1).toUpperCase() + item.substring(1);
}
