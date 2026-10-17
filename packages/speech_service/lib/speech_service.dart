/// Continuous speech recognition for dictation.
///
/// [SpeechService] is the interface the app depends on. [SpeechToTextService]
/// implements it on the platform recognisers, [AppleSpeechService] on the
/// iOS 26 SpeechAnalyzer, and [FallbackSpeechService] picks between them.
/// Tests and demos use `package:speech_service/testing.dart`.
library;

export 'src/apple_speech_service.dart';
export 'src/fallback_speech_service.dart';
export 'src/sound_level_scale.dart';
export 'src/speech_event.dart';
export 'src/speech_locale_resolver.dart';
export 'src/speech_service.dart';
export 'src/speech_to_text_service.dart';
