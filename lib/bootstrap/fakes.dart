// TODO: Delete this file when all packages are implemented.
// All classes below are temporary fakes — replace with real implementations from packages.

import 'dart:async';
import 'dart:ui' show Color, Locale;

import 'package:shared_preferences/shared_preferences.dart';

// ─── packages/features/settings ───────────────────────────────────────────────

/// TODO: Replace with ThemeModeVO from packages/features/settings.
enum FakeThemeModeVO { light, dark, system }

/// TODO: Replace with GeneralSettings from packages/features/settings.
final class FakeGeneralSettings {
  const FakeGeneralSettings({
    this.locale = const Locale('en'),
    this.themeMode = FakeThemeModeVO.system,
    this.seedColor = const Color(0xFF6200EE),
  });

  final FakeThemeModeVO themeMode;
  final Color seedColor;
  final Locale locale;

  FakeGeneralSettings copyWith({
    FakeThemeModeVO? themeMode,
    Color? seedColor,
    Locale? locale,
  }) => FakeGeneralSettings(
    themeMode: themeMode ?? this.themeMode,
    seedColor: seedColor ?? this.seedColor,
    locale: locale ?? this.locale,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakeGeneralSettings &&
          seedColor == other.seedColor &&
          themeMode == other.themeMode &&
          locale == other.locale;

  @override
  int get hashCode => Object.hash(seedColor, themeMode, locale);
}

/// TODO: Replace with Settings from packages/features/settings.
class FakeSettings {
  const FakeSettings({this.general = const FakeGeneralSettings()});

  final FakeGeneralSettings general;

  FakeSettings copyWith({FakeGeneralSettings? general}) =>
      FakeSettings(general: general ?? this.general);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FakeSettings && other.general == general);

  @override
  int get hashCode => general.hashCode;
}

/// TODO: Replace with SettingsService from packages/features/settings.
class FakeSettingsService {
  FakeSettings _current = const FakeSettings();
  final _controller = StreamController<FakeSettings>.broadcast();

  Stream<FakeSettings> get stream => _controller.stream;

  FakeSettings get current => _current;

  Future<void> update(FakeSettings Function(FakeSettings) transform) async {
    _current = transform(_current);
    _controller.add(_current);
  }

  Future<void> dispose() => _controller.close();
}

/// TODO: Replace with SettingsContainer from packages/features/settings.
class FakeSettingsContainer {
  const FakeSettingsContainer({required this.settingsService});

  final FakeSettingsService settingsService;

  /// TODO: Replace with real settings loading from SharedPreferences.
  static Future<FakeSettingsContainer> create({
    required SharedPreferencesAsync sharedPreferences,
  }) async =>
      FakeSettingsContainer(settingsService: FakeSettingsService());
}
