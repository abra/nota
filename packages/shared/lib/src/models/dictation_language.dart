import 'package:equatable/equatable.dart' show Equatable;

/// A language the speech recogniser can listen in, chosen for dictation
/// independently of the app language.
final class DictationLanguage extends Equatable {
  const DictationLanguage({required this.tag, required this.name});

  /// BCP 47 tag such as `ru-RU` or `cmn-Hans-CN`.
  final String tag;

  /// Display name from the recogniser, e.g. "Russian (Russia)". Stored with
  /// the choice so settings can show it without asking the recogniser.
  final String name;

  /// The language subtag: `ru` for `ru-RU`.
  String get languageCode => languageCodeOf(tag);

  /// The language subtag of [tag], lower-cased; `_` separators are accepted.
  static String languageCodeOf(String tag) {
    final end = tag.indexOf(RegExp('[-_]'));
    return (end < 0 ? tag : tag.substring(0, end)).toLowerCase();
  }

  @override
  List<Object> get props => [tag, name];

  @override
  String toString() => 'DictationLanguage($tag, "$name")';
}

/// [DictationLanguage]s arranged for a picker.
typedef ArrangedDictationLanguages = ({
  List<DictationLanguage> recent,
  List<DictationLanguage> others,
});

/// Orders [available] for a picker: the entries named by [recentTags] first,
/// in that order, then everything else by name. Recent tags the recogniser no
/// longer offers are skipped, and duplicate tags keep their first entry.
ArrangedDictationLanguages arrangeDictationLanguages({
  required Iterable<DictationLanguage> available,
  Iterable<String> recentTags = const [],
}) {
  final byTag = <String, DictationLanguage>{};
  for (final language in available) {
    byTag.putIfAbsent(language.tag, () => language);
  }
  final recent = [
    for (final tag in recentTags.toSet()) ?byTag.remove(tag),
  ];
  final others = byTag.values.toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return (recent: recent, others: others);
}
