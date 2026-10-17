import 'speech_service.dart';

/// Picks the recogniser locale for an app language.
///
/// Recogniser ids come in platform spellings (`en_US`, `en-US`, `EN_us`);
/// matching is case-insensitive on the language part. Preference order:
///
/// 1. exact language + [countryCode] match,
/// 2. [preferredId] (typically the device locale) if it has the language,
/// 3. the first locale with the language.
///
/// Returns `null` when no locale has the language. Returns the id in its
/// original spelling because platforms expect it back unchanged.
String? resolveSpeechLocaleId({
  required Iterable<SpeechLocale> available,
  required String languageCode,
  String? countryCode,
  String? preferredId,
}) {
  final language = languageCode.toLowerCase();
  final candidates = [
    for (final locale in available)
      if (_languageOf(locale.id) == language) locale.id,
  ];
  if (candidates.isEmpty) return null;

  if (countryCode != null) {
    final wanted = '${language}_${countryCode.toLowerCase()}';
    for (final id in candidates) {
      if (_normalize(id) == wanted) return id;
    }
  }

  if (preferredId != null) {
    final preferred = _normalize(preferredId);
    for (final id in candidates) {
      if (_normalize(id) == preferred) return id;
    }
  }

  return candidates.first;
}

String _normalize(String id) => id.toLowerCase().replaceAll('-', '_');

String _languageOf(String id) {
  final normalized = _normalize(id);
  final separator = normalized.indexOf('_');
  return separator < 0 ? normalized : normalized.substring(0, separator);
}
