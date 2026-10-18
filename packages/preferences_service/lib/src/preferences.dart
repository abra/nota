import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared/shared.dart'
    show DictationLanguage, DictationPause, NoteListDensity, NoteViewMode;

/// Stores user preferences: theme mode, locale, note view mode and
/// dictation settings.
final class Preferences {
  const Preferences({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
    this.noteViewMode = NoteViewMode.grid,
    this.noteListDensity = NoteListDensity.threeLines,
    this.dictationPause = DictationPause.normal,
    this.voiceCommands = true,
    this.dictationLanguage,
    this.recentDictationLanguages = const [],
  });

  /// How many recently picked dictation languages are remembered.
  static const maxRecentDictationLanguages = 4;

  final ThemeMode themeMode;
  final Locale locale;
  final NoteViewMode noteViewMode;
  final NoteListDensity noteListDensity;

  /// Silence that ends a dictated phrase.
  final DictationPause dictationPause;

  /// Whether spoken commands ("new line", "undo", …) are recognised.
  final bool voiceCommands;

  /// Language dictation listens in; `null` follows [locale].
  final DictationLanguage? dictationLanguage;

  /// Tags of the dictation languages picked lately, newest first.
  final List<String> recentDictationLanguages;

  Preferences copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    NoteViewMode? noteViewMode,
    NoteListDensity? noteListDensity,
    DictationPause? dictationPause,
    bool? voiceCommands,
  }) => Preferences(
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
    noteViewMode: noteViewMode ?? this.noteViewMode,
    noteListDensity: noteListDensity ?? this.noteListDensity,
    dictationPause: dictationPause ?? this.dictationPause,
    voiceCommands: voiceCommands ?? this.voiceCommands,
    dictationLanguage: dictationLanguage,
    recentDictationLanguages: recentDictationLanguages,
  );

  /// Picks the dictation language and moves it to the front of
  /// [recentDictationLanguages]; `null` follows the app language again.
  Preferences withDictationLanguage(DictationLanguage? language) => Preferences(
    themeMode: themeMode,
    locale: locale,
    noteViewMode: noteViewMode,
    noteListDensity: noteListDensity,
    dictationPause: dictationPause,
    voiceCommands: voiceCommands,
    dictationLanguage: language,
    recentDictationLanguages: language == null
        ? recentDictationLanguages
        : List.unmodifiable(
            [
              language.tag,
              ...recentDictationLanguages.where((tag) => tag != language.tag),
            ].take(maxRecentDictationLanguages),
          ),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Preferences &&
          themeMode == other.themeMode &&
          locale == other.locale &&
          noteViewMode == other.noteViewMode &&
          noteListDensity == other.noteListDensity &&
          dictationPause == other.dictationPause &&
          voiceCommands == other.voiceCommands &&
          dictationLanguage == other.dictationLanguage &&
          listEquals(recentDictationLanguages, other.recentDictationLanguages);

  @override
  int get hashCode => Object.hash(
    themeMode,
    locale,
    noteViewMode,
    noteListDensity,
    dictationPause,
    voiceCommands,
    dictationLanguage,
    Object.hashAll(recentDictationLanguages),
  );
}
