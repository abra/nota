import 'package:flutter_test/flutter_test.dart';
import 'package:speech_service/speech_service.dart';

void main() {
  const locales = [
    SpeechLocale(id: 'en_US', name: 'English (US)'),
    SpeechLocale(id: 'en-GB', name: 'English (UK)'),
    SpeechLocale(id: 'ru_RU', name: 'Русский'),
    SpeechLocale(id: 'pt_BR', name: 'Português (Brasil)'),
    SpeechLocale(id: 'pt_PT', name: 'Português (Portugal)'),
  ];

  group('resolveSpeechLocaleId', () {
    test('prefers the exact country match, whatever the separator', () {
      expect(
        resolveSpeechLocaleId(
          available: locales,
          languageCode: 'en',
          countryCode: 'GB',
        ),
        'en-GB',
      );
      expect(
        resolveSpeechLocaleId(
          available: locales,
          languageCode: 'pt',
          countryCode: 'PT',
        ),
        'pt_PT',
      );
    });

    test('falls back to the preferred id when it has the language', () {
      expect(
        resolveSpeechLocaleId(
          available: locales,
          languageCode: 'pt',
          preferredId: 'pt-BR',
        ),
        'pt_BR',
      );
    });

    test('ignores the preferred id when its language differs', () {
      expect(
        resolveSpeechLocaleId(
          available: locales,
          languageCode: 'ru',
          preferredId: 'en_US',
        ),
        'ru_RU',
      );
    });

    test('takes the first locale with the language otherwise', () {
      expect(
        resolveSpeechLocaleId(available: locales, languageCode: 'en'),
        'en_US',
      );
    });

    test('is case-insensitive on the language code', () {
      expect(
        resolveSpeechLocaleId(available: locales, languageCode: 'RU'),
        'ru_RU',
      );
    });

    test('returns null when the language is missing', () {
      expect(
        resolveSpeechLocaleId(available: locales, languageCode: 'ja'),
        isNull,
      );
      expect(
        resolveSpeechLocaleId(available: const [], languageCode: 'en'),
        isNull,
      );
    });
  });

  group('SoundLevelScale', () {
    test('maps the platform range onto 0..1 and clamps outside it', () {
      const scale = SoundLevelScale(silence: -50, loud: -10);
      expect(scale.normalize(-50), 0);
      expect(scale.normalize(-30), 0.5);
      expect(scale.normalize(-10), 1);
      expect(scale.normalize(-90), 0);
      expect(scale.normalize(5), 1);
    });
  });
}
