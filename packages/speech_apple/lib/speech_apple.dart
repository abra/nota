/// Dart face of the iOS SpeechAnalyzer plugin.
///
/// [SpeechApple] talks to the native side; everything else in the app goes
/// through `package:speech_service`, which adapts it to [SpeechService].
library;

export 'src/speech_apple.dart';
export 'src/speech_apple_event.dart';
