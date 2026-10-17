# speech_service

Continuous speech recognition for dictating notes.

## Why this package exists

The platform recognisers (SFSpeechRecognizer on iOS, SpeechRecognizer on
Android) work one utterance at a time: they stop after a pause or a time
limit and have to be started again. `SpeechService` hides that behind a
session that keeps listening until it is stopped, and exposes the pause
between utterances as a setting because the editor uses it to split dictated
list items.

## Implementations

- `SpeechToTextService` — the `speech_to_text` plugin (SFSpeechRecognizer,
  Android SpeechRecognizer) wrapped in a restart loop.
- `AppleSpeechService` — the iOS 26 SpeechAnalyzer through
  `package:speech_apple`; one session, no time limit, on-device models.
- `FallbackSpeechService` — prefers the Apple service and falls back to the
  classic one when the device, the locale or the model download rules it
  out, within the same `start` call.

## API

```dart
final service = SpeechToTextService();

switch (await service.initialize()) {
  case SpeechAvailability.available: break;
  case SpeechAvailability.permissionDenied: // explain how to grant access
  case SpeechAvailability.unavailable:      // hide the feature
}

final localeId = resolveSpeechLocaleId(
  available: await service.supportedLocales(),
  languageCode: 'ru',
);

final sub = service.events.listen((event) {
  switch (event) {
    case SpeechTranscript(:final text, :final isFinal): // show or commit
    case SpeechSoundLevel(:final level):                 // 0..1 for a meter
    case SpeechFailure(:final reason):                   // session ended
  }
});

await service.start(SpeechSessionConfig(
  localeId: localeId,
  segmentPause: const Duration(milliseconds: 1400),
  contextualPhrases: const ['new line', 'undo'],
));
// ...
await service.stop();
```

Each utterance yields partial transcripts followed by one final transcript.
Partials are not cumulative across utterances.

## Behaviour worth knowing

- **Pauses.** `initialPause` applies until the first words are heard, then
  `segmentPause` takes over. The long initial pause stops an idle microphone
  from cycling sessions; on Android every session start plays the system
  prompt sound.
- **Restarts.** After every utterance the recogniser is started again after
  `restartDelay`. Speech during that gap (a few hundred milliseconds) is
  lost, which is why the pause should match how people dictate: short for
  lists, longer for prose.
- **Errors.** "Nothing was said" errors end the utterance silently. Network
  and unknown errors are retried with exponential backoff and become a
  `SpeechFailure` after `maxConsecutiveFailures`. Permission and language
  errors fail immediately.
- **Sound level.** Raw platform values differ (dB on iOS, RMS dB on
  Android); `SoundLevelScale` maps both onto `0..1`.
- **iOS server limit.** Without on-device recognition Apple stops a request
  after about a minute. That surfaces as a finished utterance and the
  session carries on.

## Platform setup

iOS `Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>…</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>…</string>
```

Android `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<queries>
  <intent>
    <action android:name="android.speech.RecognitionService" />
  </intent>
</queries>
```

## Testing

`package:speech_service/testing.dart` provides `ScriptedSpeechService`, an
in-memory implementation that records calls and lets a test push
transcripts, levels and failures.
