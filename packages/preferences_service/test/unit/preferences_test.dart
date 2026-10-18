import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart' show DictationLanguage;

void main() {
  const ru = DictationLanguage(tag: 'ru-RU', name: 'Русский');
  const en = DictationLanguage(tag: 'en-US', name: 'English (US)');
  const de = DictationLanguage(tag: 'de-DE', name: 'Deutsch');
  const fr = DictationLanguage(tag: 'fr-FR', name: 'Français');
  const es = DictationLanguage(tag: 'es-ES', name: 'Español');

  group('Preferences.withDictationLanguage', () {
    test('sets the language and puts it first among the recent ones', () {
      final prefs = const Preferences()
          .withDictationLanguage(ru)
          .withDictationLanguage(en);

      expect(prefs.dictationLanguage, en);
      expect(prefs.recentDictationLanguages, ['en-US', 'ru-RU']);
    });

    test('moves a repeated pick to the front without duplicating it', () {
      final prefs = const Preferences()
          .withDictationLanguage(ru)
          .withDictationLanguage(en)
          .withDictationLanguage(ru);

      expect(prefs.recentDictationLanguages, ['ru-RU', 'en-US']);
    });

    test('remembers a bounded number of languages', () {
      var prefs = const Preferences();
      for (final language in [ru, en, de, fr, es]) {
        prefs = prefs.withDictationLanguage(language);
      }

      expect(
        prefs.recentDictationLanguages,
        hasLength(Preferences.maxRecentDictationLanguages),
      );
      expect(prefs.recentDictationLanguages.first, 'es-ES');
      expect(prefs.recentDictationLanguages, isNot(contains('ru-RU')));
    });

    test('null follows the app language and keeps the recent list', () {
      final prefs = const Preferences()
          .withDictationLanguage(ru)
          .withDictationLanguage(null);

      expect(prefs.dictationLanguage, isNull);
      expect(prefs.recentDictationLanguages, ['ru-RU']);
    });

    test('copyWith keeps the dictation language', () {
      final prefs = const Preferences()
          .withDictationLanguage(ru)
          .copyWith(themeMode: ThemeMode.dark);

      expect(prefs.dictationLanguage, ru);
      expect(prefs.recentDictationLanguages, ['ru-RU']);
    });

    test('equality covers the dictation language and the recent list', () {
      final a = const Preferences().withDictationLanguage(ru);
      final b = const Preferences().withDictationLanguage(ru);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const Preferences()));
      expect(
        a.withDictationLanguage(null),
        isNot(const Preferences()),
        reason: 'the recent list still differs',
      );
    });
  });
}
