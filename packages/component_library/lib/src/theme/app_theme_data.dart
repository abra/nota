import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'nord.dart';

const _fontFamily = 'Geist';

// M3 default sizes + 2pt, Geist typeface. Titles carry a semi-bold weight so
// hierarchy reads without relying on size alone.
const _textTheme = TextTheme(
  displayLarge: TextStyle(fontSize: 59, letterSpacing: -0.5),
  displayMedium: TextStyle(fontSize: 47, letterSpacing: -0.5),
  displaySmall: TextStyle(fontSize: 38, letterSpacing: -0.25),
  headlineLarge: TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  ),
  headlineMedium: TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  ),
  headlineSmall: TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  ),
  titleLarge: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  ),
  titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  bodyLarge: TextStyle(fontSize: 18),
  bodyMedium: TextStyle(fontSize: 16),
  bodySmall: TextStyle(fontSize: 16),
  labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
  labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  labelSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
);

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

/// Light variant of [AppThemeData] — Nord, Frost blue accent.
final class LightAppThemeData extends AppThemeData {
  const LightAppThemeData();

  @override
  ThemeData get materialThemeData => _buildTheme(
    scaffoldBackground: NordSnowStorm.nord6,
    colorScheme: const ColorScheme.light(
      primary: NordFrost.nord10,
      onPrimary: Colors.white,
      primaryContainer: NordSnowStorm.nord4,
      onPrimaryContainer: NordFrost.nord10,
      secondary: NordFrost.nord9,
      onSecondary: Colors.white,
      surface: NordSnowStorm.nord6,
      onSurface: NordPolarNight.nord0,
      onSurfaceVariant: NordPolarNight.nord3,
      outline: NordPolarNight.nord3,
      outlineVariant: NordSnowStorm.nord4,
      error: NordAurora.nord11,
      onError: Colors.white,
      surfaceBright: Colors.white,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: NordSnowStorm.nord5,
      surfaceContainer: NordSnowStorm.nord5,
      surfaceContainerHigh: NordSnowStorm.nord4,
      surfaceContainerHighest: NordSnowStorm.nord4,
    ),
  );
}

/// Dark variant of [AppThemeData] — Nord, Frost blue accent.
final class DarkAppThemeData extends AppThemeData {
  const DarkAppThemeData();

  @override
  ThemeData get materialThemeData => _buildTheme(
    scaffoldBackground: NordPolarNight.nord0,
    colorScheme: const ColorScheme.dark(
      primary: NordFrost.nord8,
      onPrimary: NordPolarNight.nord0,
      primaryContainer: NordPolarNight.nord2,
      onPrimaryContainer: NordFrost.nord8,
      secondary: NordFrost.nord9,
      onSecondary: NordPolarNight.nord0,
      surface: NordPolarNight.nord0,
      onSurface: NordSnowStorm.nord6,
      onSurfaceVariant: NordSnowStorm.nord4,
      outline: NordPolarNight.nord3,
      outlineVariant: NordPolarNight.nord2,
      error: NordAurora.nord11,
      onError: NordPolarNight.nord0,
      surfaceBright: NordPolarNight.nord1,
      surfaceContainerLowest: NordPolarNight.nord0,
      surfaceContainerLow: NordPolarNight.nord1,
      surfaceContainer: NordPolarNight.nord1,
      surfaceContainerHigh: NordPolarNight.nord2,
      surfaceContainerHighest: NordPolarNight.nord3,
    ),
  );
}

/// Builds the shared [ThemeData] for both brightnesses.
///
/// Component themes live here so features only pick Material widgets and get
/// the Nota look for free: flat cards with soft corners, floating sheets with
/// a drag handle, pill segmented buttons and platform-native page transitions.
ThemeData _buildTheme({
  required ColorScheme colorScheme,
  required Color scaffoldBackground,
}) {
  final isDark = colorScheme.brightness == Brightness.dark;
  final textTheme = _textTheme.apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    fontFamily: _fontFamily,
    textTheme: textTheme,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBackground,
    splashFactory: InkSparkle.splashFactory,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scaffoldBackground,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: isDark ? NordPolarNight.nord1 : Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.mediumLarge)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceBright,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: colorScheme.surfaceBright,
      showDragHandle: true,
      dragHandleColor: colorScheme.outlineVariant,
      dragHandleSize: const Size(36, 4),
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xLarge),
        ),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        side: WidgetStatePropertyAll(
          BorderSide(color: colorScheme.outlineVariant),
        ),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.primaryContainer
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
          ),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
        ),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colorScheme.surfaceBright,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.mediumLarge)),
      ),
      textStyle: textTheme.bodyMedium,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceBright,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xLarge)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.small)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: colorScheme.primary,
      selectionColor: colorScheme.primary.withValues(alpha: 0.3),
      selectionHandleColor: colorScheme.primary,
    ),
  );
}
