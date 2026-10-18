import 'package:shared/shared.dart';
import 'package:test/test.dart';

void main() {
  const ru = DictationLanguage(tag: 'ru-RU', name: 'Russian (Russia)');
  const enUs = DictationLanguage(tag: 'en-US', name: 'English (US)');
  const enGb = DictationLanguage(tag: 'en-GB', name: 'English (UK)');
  const de = DictationLanguage(tag: 'de-DE', name: 'german (Germany)');

  group('DictationLanguage', () {
    test('compares by tag and name', () {
      expect(
        const DictationLanguage(tag: 'ru-RU', name: 'Russian (Russia)'),
        ru,
      );
      expect(const DictationLanguage(tag: 'ru-RU', name: 'Русский'), isNot(ru));
    });

    test('languageCodeOf takes the first subtag, lower-cased', () {
      expect(DictationLanguage.languageCodeOf('ru-RU'), 'ru');
      expect(DictationLanguage.languageCodeOf('EN_us'), 'en');
      expect(DictationLanguage.languageCodeOf('cmn-Hans-CN'), 'cmn');
      expect(DictationLanguage.languageCodeOf('fr'), 'fr');
      expect(ru.languageCode, 'ru');
    });
  });

  group('arrangeDictationLanguages', () {
    test('puts recent tags first, in their order, the rest by name', () {
      final arranged = arrangeDictationLanguages(
        available: [ru, enUs, de, enGb],
        recentTags: ['en-GB', 'ru-RU'],
      );

      expect(arranged.recent, [enGb, ru]);
      expect(arranged.others, [enUs, de], reason: 'sorted ignoring case');
    });

    test('skips recent tags the recogniser no longer offers', () {
      final arranged = arrangeDictationLanguages(
        available: [ru, enUs],
        recentTags: ['sw-KE', 'ru-RU'],
      );

      expect(arranged.recent, [ru]);
      expect(arranged.others, [enUs]);
    });

    test('keeps the first entry of a duplicated tag', () {
      const ruAgain = DictationLanguage(tag: 'ru-RU', name: 'ru-RU');
      final arranged = arrangeDictationLanguages(
        available: [ru, ruAgain, enUs],
        recentTags: ['ru-RU', 'ru-RU'],
      );

      expect(arranged.recent, [ru]);
      expect(arranged.others, [enUs]);
    });

    test('without recents everything is sorted by name', () {
      final arranged = arrangeDictationLanguages(available: [ru, enUs, enGb]);

      expect(arranged.recent, isEmpty);
      expect(arranged.others, [enGb, enUs, ru]);
    });
  });
}
