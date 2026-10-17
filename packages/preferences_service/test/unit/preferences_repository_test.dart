import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:preferences_service/preferences_service.dart';
import 'package:shared/shared.dart' show DictationPause, NoteViewMode;
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

const _supportedCodes = ['en', 'ru'];

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('PreferencesRepository', () {
    test('load() returns defaults when storage is empty', () async {
      final repo = PreferencesRepository(PreferencesStorage());

      final prefs = await repo.load(_supportedCodes);

      expect(prefs, const Preferences());
    });

    test('load() restores preferences saved by save()', () async {
      final repo = PreferencesRepository(PreferencesStorage());
      const saved = Preferences(
        themeMode: ThemeMode.dark,
        locale: Locale('ru'),
        noteViewMode: NoteViewMode.list,
        dictationPause: DictationPause.long,
        voiceCommands: false,
      );

      await repo.save(saved);
      final loaded = await repo.load(_supportedCodes);

      expect(loaded, saved);
    });

    test(
      'load() defaults the dictation settings missing from older data',
      () async {
        final storage = PreferencesStorage();
        await storage.setString(
          'app_preferences',
          '{"themeMode":"dark","locale":"en","noteViewMode":"grid","noteListDensity":"threeLines"}',
        );

        final repo = PreferencesRepository(storage);
        final prefs = await repo.load(_supportedCodes);

        expect(prefs.themeMode, ThemeMode.dark);
        expect(prefs.dictationPause, DictationPause.normal);
        expect(prefs.voiceCommands, isTrue);
      },
    );

    test('load() returns defaults when stored JSON is corrupted', () async {
      final storage = PreferencesStorage();
      await storage.setString('app_preferences', 'not valid json');

      final repo = PreferencesRepository(storage);
      final prefs = await repo.load(_supportedCodes);

      expect(prefs, const Preferences());
    });

    test('load() falls back when cached locale is unsupported', () async {
      final storage = PreferencesStorage();
      await storage.setString(
        'app_preferences',
        '{"themeMode":"system","locale":"xx","noteViewMode":"grid","noteListDensity":"threeLines"}',
      );

      final repo = PreferencesRepository(storage);
      final prefs = await repo.load(_supportedCodes);

      expect(prefs.locale.languageCode, isIn(_supportedCodes));
    });
  });
}
