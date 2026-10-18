import 'package:shared/shared.dart' show DictationLanguage;
import 'package:speech_service/speech_service.dart';

/// Languages [service] can listen in, as picker entries.
///
/// Initialises the service first, which may ask for microphone and speech
/// recognition access. Empty when the recogniser is unusable or cannot list
/// its languages.
Future<List<DictationLanguage>> loadDictationLanguages(
  SpeechService service,
) async {
  if (await service.initialize() != SpeechAvailability.available) {
    return const [];
  }
  final locales = await service.supportedLocales();
  return [
    for (final locale in locales)
      DictationLanguage(tag: locale.tag, name: locale.displayName),
  ];
}
