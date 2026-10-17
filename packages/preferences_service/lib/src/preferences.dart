import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared/shared.dart'
    show DictationPause, NoteListDensity, NoteViewMode;

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
  });

  final ThemeMode themeMode;
  final Locale locale;
  final NoteViewMode noteViewMode;
  final NoteListDensity noteListDensity;

  /// Silence that ends a dictated phrase.
  final DictationPause dictationPause;

  /// Whether spoken commands ("new line", "undo", …) are recognised.
  final bool voiceCommands;

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
          voiceCommands == other.voiceCommands;

  @override
  int get hashCode => Object.hash(
    themeMode,
    locale,
    noteViewMode,
    noteListDensity,
    dictationPause,
    voiceCommands,
  );
}
