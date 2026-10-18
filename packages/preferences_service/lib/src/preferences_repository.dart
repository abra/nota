import 'dart:convert' show jsonDecode, jsonEncode;
import 'dart:ui' show Locale, PlatformDispatcher;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared/shared.dart'
    show DictationLanguage, DictationPause, NoteListDensity, NoteViewMode;

import 'preferences.dart';
import 'preferences_storage.dart';

/// Loads and persists [Preferences] via [PreferencesStorage].
class PreferencesRepository {
  PreferencesRepository(this._storage);

  static const _key = 'app_preferences';

  final PreferencesStorage _storage;

  Future<Preferences> load(List<String> supportedCodes) async {
    final json = await _storage.getString(_key);
    if (json == null) {
      return Preferences(locale: _resolveInitialLocale(supportedCodes));
    }
    try {
      final map = jsonDecode(json) as Map<String, Object?>;
      return Preferences(
        themeMode: ThemeMode.values.byName(
          map['themeMode'] as String? ?? 'system',
        ),
        locale: _resolveLocale(map['locale'] as String?, supportedCodes),
        noteViewMode: NoteViewMode.values.byName(
          map['noteViewMode'] as String? ?? 'grid',
        ),
        noteListDensity: NoteListDensity.values.byName(
          map['noteListDensity'] as String? ?? 'threeLines',
        ),
        // Added later; older installs have no such keys.
        dictationPause: DictationPause.values.byName(
          map['dictationPause'] as String? ?? 'normal',
        ),
        voiceCommands: map['voiceCommands'] as bool? ?? true,
        dictationLanguage: _dictationLanguageFrom(map['dictationLanguage']),
        recentDictationLanguages: List.unmodifiable([
          ...?(map['recentDictationLanguages'] as List?)?.whereType<String>(),
        ]),
      );
    } catch (_) {
      return const Preferences();
    }
  }

  Future<void> save(Preferences prefs) async {
    final map = <String, Object?>{
      'themeMode': prefs.themeMode.name,
      'locale': prefs.locale.languageCode,
      'noteViewMode': prefs.noteViewMode.name,
      'noteListDensity': prefs.noteListDensity.name,
      'dictationPause': prefs.dictationPause.name,
      'voiceCommands': prefs.voiceCommands,
      if (prefs.dictationLanguage case final language?)
        'dictationLanguage': {'tag': language.tag, 'name': language.name},
      'recentDictationLanguages': prefs.recentDictationLanguages,
    };
    await _storage.setString(_key, jsonEncode(map));
  }

  /// A malformed entry falls back to the app language instead of resetting
  /// every other preference.
  static DictationLanguage? _dictationLanguageFrom(Object? value) {
    if (value case {'tag': final String tag, 'name': final String name}) {
      return DictationLanguage(tag: tag, name: name);
    }
    return null;
  }

  static Locale _resolveLocale(String? code, List<String> supportedCodes) {
    if (code != null && supportedCodes.contains(code)) return Locale(code);
    return _resolveInitialLocale(supportedCodes);
  }

  static Locale _resolveInitialLocale(List<String> supportedCodes) {
    final code = PlatformDispatcher.instance.locale.languageCode;
    return Locale(supportedCodes.contains(code) ? code : 'en');
  }
}
