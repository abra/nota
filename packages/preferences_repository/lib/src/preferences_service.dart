import 'dart:async';
import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;

import 'preferences.dart';
import 'preferences_storage.dart';

/// Loads, persists and streams [Preferences].
class PreferencesService {
  PreferencesService._(this._prefs, this._current);

  static const _key = 'app_preferences';

  final PreferencesStorage _prefs;
  final _controller = StreamController<Preferences>.broadcast();
  Preferences _current;

  static Future<PreferencesService> create() async {
    final prefs = PreferencesStorage();
    final settings = await _load(prefs);
    return PreferencesService._(prefs, settings);
  }

  Stream<Preferences> get stream => _controller.stream;

  Preferences get current => _current;

  Future<void> update(Preferences Function(Preferences) transform) async {
    _current = transform(_current);
    await _save(_prefs, _current);
    _controller.add(_current);
  }

  static Future<Preferences> _load(PreferencesStorage prefs) async {
    final json = await prefs.getString(_key);
    if (json == null) return const Preferences();
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      return Preferences(
        themeMode: ThemeMode.values.byName(
          map['themeMode'] as String? ?? 'system',
        ),
        locale: Locale(map['locale'] as String? ?? 'en'),
      );
    } catch (_) {
      return const Preferences();
    }
  }

  static Future<void> _save(PreferencesStorage prefs, Preferences s) async {
    final map = <String, Object?>{
      'themeMode': s.themeMode.name,
      'locale': s.locale.languageCode,
    };
    await prefs.setString(_key, jsonEncode(map));
  }
}
