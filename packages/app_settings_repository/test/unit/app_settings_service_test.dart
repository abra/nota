import 'dart:ui' show Locale;

import 'package:app_settings_repository/app_settings_repository.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:app_settings_repository/src/preferences_storage.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('AppSettingsService', () {
    test('create() returns default settings when prefs is empty', () async {
      final service = await AppSettingsService.create();

      expect(service.current, const AppSettings());
    });

    test('update() changes current settings', () async {
      final service = await AppSettingsService.create();

      await service.update((s) => s.copyWith(themeMode: ThemeMode.dark));

      expect(service.current.themeMode, ThemeMode.dark);
    });

    test('update() emits updated settings on stream', () async {
      final service = await AppSettingsService.create();

      expectLater(
        service.stream,
        emits(
          isA<AppSettings>().having(
            (s) => s.themeMode,
            'themeMode',
            ThemeMode.dark,
          ),
        ),
      );

      await service.update((s) => s.copyWith(themeMode: ThemeMode.dark));
    });

    test('settings persist across service recreations', () async {
      final service = await AppSettingsService.create();
      await service.update((s) => s.copyWith(themeMode: ThemeMode.dark));

      final service2 = await AppSettingsService.create();

      expect(service2.current.themeMode, ThemeMode.dark);
    });

    test('persists locale correctly', () async {
      final service = await AppSettingsService.create();
      await service.update((s) => s.copyWith(locale: const Locale('ru')));

      final service2 = await AppSettingsService.create();

      expect(service2.current.locale, const Locale('ru'));
    });

    test('create() returns defaults when stored data is corrupted', () async {
      await PreferencesStorage().setString('app_settings', 'not valid json');

      final service = await AppSettingsService.create();

      expect(service.current, const AppSettings());
    });
  });
}
