# speech_apple

iOS-only Flutter plugin that runs continuous dictation through the
SpeechAnalyzer API introduced in iOS 26.

## Why this package exists

SFSpeechRecognizer (used by `speech_to_text`) stops after about a minute,
leans on the network for many languages and has to be restarted after every
utterance. SpeechAnalyzer keeps one on-device session alive for as long as
needed. The app prefers it when available and falls back otherwise (see
`FallbackSpeechService` in `package:speech_service`).

## How the native side works

- One `DictationSession` actor owns an `AVAudioEngine` input tap, converts
  the microphone buffers to the analyzer's preferred format and feeds them
  to a `SpeechTranscriber` with volatile results enabled.
- Volatile results stream to Dart as partial transcripts. When the text
  stops changing for the configured pause, the session asks the analyzer to
  finalize, which yields the final transcript for that utterance. The
  transcriber also finalizes at sentence ends on its own.
- The speech model for the locale is downloaded on first use through
  `AssetInventory`.
- Microphone permission is the only one required.

## Dart API

```dart
final speech = SpeechApple();
if (await speech.isSupported() && await speech.requestPermissions()) {
  final ids = await speech.supportedLocales();          // ['en-US', ...]
  speech.events.listen((event) { /* transcript / level / error */ });
  await speech.start(localeId: 'en-US', segmentPause: const Duration(milliseconds: 1400));
  await speech.stop();
}
```

The simulator has no speech models; test on a device running iOS 26.
