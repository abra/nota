import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:ui_settings/src/preferences_storage.dart';
import 'package:ui_settings/src/ui_settings.dart';

/// Loads, persists and streams [UiSettings].
class UiSettingsService {
  UiSettingsService._(this._prefs, this._current);

  static const _key = 'app_settings';

  final PreferencesStorage _prefs;
  final _controller = StreamController<UiSettings>.broadcast();
  UiSettings _current;

  static Future<UiSettingsService> create() async {
    final prefs = PreferencesStorage();
    final settings = await _load(prefs);
    return UiSettingsService._(prefs, settings);
  }

  Stream<UiSettings> get stream => _controller.stream;

  UiSettings get current => _current;

  Future<void> update(UiSettings Function(UiSettings) transform) async {
    _current = transform(_current);
    await _save(_prefs, _current);
    _controller.add(_current);
  }

  static Future<UiSettings> _load(PreferencesStorage prefs) async {
    final json = await prefs.getString(_key);
    if (json == null) return const UiSettings();
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      return UiSettings(
        themeMode: ThemeMode.values.byName(
          map['themeMode'] as String? ?? 'system',
        ),
        locale: Locale(map['locale'] as String? ?? 'en'),
      );
    } catch (_) {
      return const UiSettings();
    }
  }

  static Future<void> _save(PreferencesStorage prefs, UiSettings s) async {
    final map = <String, Object?>{
      'themeMode': s.themeMode.name,
      'locale': s.locale.languageCode,
    };
    await prefs.setString(_key, jsonEncode(map));
  }
}
