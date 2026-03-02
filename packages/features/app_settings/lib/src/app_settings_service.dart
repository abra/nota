import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Color, Locale;

import 'package:app_settings/src/app_settings.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// Loads, persists and streams [AppSettings].
class AppSettingsService {
  AppSettingsService._(this._prefs, this._current);

  static const _key = 'app_settings';

  final SharedPreferencesAsync _prefs;
  final _controller = StreamController<AppSettings>.broadcast();
  AppSettings _current;

  static Future<AppSettingsService> create(SharedPreferencesAsync prefs) async {
    final settings = await _load(prefs);
    return AppSettingsService._(prefs, settings);
  }

  Stream<AppSettings> get stream => _controller.stream;

  AppSettings get current => _current;

  Future<void> update(AppSettings Function(AppSettings) transform) async {
    _current = transform(_current);
    await _save(_prefs, _current);
    _controller.add(_current);
  }

  static Future<AppSettings> _load(SharedPreferencesAsync prefs) async {
    final json = await prefs.getString(_key);
    if (json == null) return const AppSettings();
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      final colorMap = map['seedColor'] as Map<String, Object?>?;
      return AppSettings(
        themeMode: ThemeMode.values.byName(map['themeMode'] as String? ?? 'system'),
        seedColor: colorMap != null
            ? Color.from(
                alpha: (colorMap['a'] as num).toDouble(),
                red: (colorMap['r'] as num).toDouble(),
                green: (colorMap['g'] as num).toDouble(),
                blue: (colorMap['b'] as num).toDouble(),
              )
            : const Color(0xFF6200EE),
        locale: Locale(map['locale'] as String? ?? 'en'),
      );
    } catch (_) {
      return const AppSettings();
    }
  }

  static Future<void> _save(SharedPreferencesAsync prefs, AppSettings s) async {
    final map = <String, Object?>{
      'themeMode': s.themeMode.name,
      'seedColor': {
        'a': s.seedColor.a,
        'r': s.seedColor.r,
        'g': s.seedColor.g,
        'b': s.seedColor.b,
      },
      'locale': s.locale.languageCode,
    };
    await prefs.setString(_key, jsonEncode(map));
  }
}
