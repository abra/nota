import 'dart:ui' show Locale;

import 'package:flutter/material.dart' show ThemeMode;

/// Stores user preferences: theme mode and locale.
final class Preferences {
  const Preferences({
    this.themeMode = ThemeMode.system,
    this.locale = const Locale('en'),
  });

  final ThemeMode themeMode;
  final Locale locale;

  Preferences copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) => Preferences(
    themeMode: themeMode ?? this.themeMode,
    locale: locale ?? this.locale,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Preferences &&
          themeMode == other.themeMode &&
          locale == other.locale;

  @override
  int get hashCode => Object.hash(themeMode, locale);
}
