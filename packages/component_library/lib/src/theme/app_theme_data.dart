import 'package:flutter/material.dart';

/// Abstract base class describing the app's theme.
///
/// Extend this class to add custom colors for new components:
/// ```dart
/// Color get noteCardBackgroundColor;
/// ```
/// Then implement the value in [LightAppThemeData] and [DarkAppThemeData].
abstract class AppThemeData {
  const AppThemeData();

  /// The Material [ThemeData] passed to [MaterialApp.theme] or [MaterialApp.darkTheme].
  ThemeData get materialThemeData;
}

/// Light variant of [AppThemeData].
final class LightAppThemeData extends AppThemeData {
  const LightAppThemeData();

  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.light,
  );
}

/// Dark variant of [AppThemeData].
final class DarkAppThemeData extends AppThemeData {
  const DarkAppThemeData();

  @override
  ThemeData get materialThemeData => ThemeData(
    brightness: Brightness.dark,
  );
}
