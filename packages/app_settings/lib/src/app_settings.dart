import 'dart:ui' show Color, Locale;

import 'package:flutter/material.dart' show ThemeMode;

/// Stores user preferences: theme mode, seed color and locale.
final class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.seedColor = const Color(0xFF6200EE),
    this.locale = const Locale('en'),
  });

  final ThemeMode themeMode;
  final Color seedColor;
  final Locale locale;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    Locale? locale,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    seedColor: seedColor ?? this.seedColor,
    locale: locale ?? this.locale,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          themeMode == other.themeMode &&
          seedColor == other.seedColor &&
          locale == other.locale;

  @override
  int get hashCode => Object.hash(themeMode, seedColor, locale);
}
