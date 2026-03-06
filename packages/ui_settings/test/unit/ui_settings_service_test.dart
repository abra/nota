import 'dart:ui' show Locale;

import 'package:ui_settings/ui_settings.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_settings/src/preferences_storage.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  group('UiSettingsService', () {
    test('create() returns default settings when prefs is empty', () async {
      final service = await UiSettingsService.create();

      expect(service.current, const UiSettings());
    });

    test('update() changes current settings', () async {
      final service = await UiSettingsService.create();

      await service.update((s) => s.copyWith(themeMode: ThemeMode.dark));

      expect(service.current.themeMode, ThemeMode.dark);
    });

    test('update() emits updated settings on stream', () async {
      final service = await UiSettingsService.create();

      expectLater(
        service.stream,
        emits(
          isA<UiSettings>().having(
            (s) => s.themeMode,
            'themeMode',
            ThemeMode.dark,
          ),
        ),
      );

      await service.update((s) => s.copyWith(themeMode: ThemeMode.dark));
    });

    test('settings persist across service recreations', () async {
      final service = await UiSettingsService.create();
      await service.update((s) => s.copyWith(themeMode: ThemeMode.dark));

      final service2 = await UiSettingsService.create();

      expect(service2.current.themeMode, ThemeMode.dark);
    });

    test('persists locale correctly', () async {
      final service = await UiSettingsService.create();
      await service.update((s) => s.copyWith(locale: const Locale('ru')));

      final service2 = await UiSettingsService.create();

      expect(service2.current.locale, const Locale('ru'));
    });

    test('create() returns defaults when stored data is corrupted', () async {
      await PreferencesStorage().setString('app_settings', 'not valid json');

      final service = await UiSettingsService.create();

      expect(service.current, const UiSettings());
    });
  });
}
