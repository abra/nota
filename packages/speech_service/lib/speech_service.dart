/// Continuous speech recognition for dictation.
///
/// [SpeechService] is the interface the app depends on; [SpeechToTextService]
/// implements it on top of the platform recognisers. Tests and demos use
/// `package:speech_service/testing.dart`.
library;

export 'src/sound_level_scale.dart';
export 'src/speech_event.dart';
export 'src/speech_locale_resolver.dart';
export 'src/speech_service.dart';
export 'src/speech_to_text_service.dart';
