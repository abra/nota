import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;

/// Stores user preferences: theme mode and locale.
final class UiSettings {
  const UiSettings({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });

  final ThemeMode themeMode;
  final Locale locale;

  UiSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) => UiSettings(
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UiSettings &&
          themeMode == other.themeMode &&
          locale == other.locale;

  @override
  int get hashCode => Object.hash(themeMode, locale);
}
