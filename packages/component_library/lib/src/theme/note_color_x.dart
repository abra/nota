import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'nord.dart';

/// Maps [NoteColor] domain values to Flutter [Color].
///
/// Light theme uses soft pastels. Dark theme re-derives each swatch in HSL
/// with low saturation and lightness so a coloured note reads as a tinted
/// dark card instead of a glowing pastel on a dark background.
extension NoteColorX on NoteColor {
  /// Pastel swatch used in the light theme.
  Color get color => switch (this) {
    NoteColor.none => Colors.transparent,
    NoteColor.red => const Color(0xFFF5A29D),
    NoteColor.orange => const Color(0xFFFFC26C),
    NoteColor.yellow => const Color(0xFFFFEE8D),
    NoteColor.green => const Color(0xFFA4E1A1),
    NoteColor.teal => const Color(0xFF82D7E0),
    NoteColor.blue => const Color(0xFF8EC6F7),
    NoteColor.purple => const Color(0xFFCDA5E0),
    NoteColor.pink => const Color(0xFFFFB2E0),
    NoteColor.lime => const Color(0xFFC9F391),
    NoteColor.indigo => const Color(0xFFB1B5FF),
    NoteColor.brown => const Color(0xFFE1B995),
    NoteColor.coral => const Color(0xFFFFA68D),
    NoteColor.mint => const Color(0xFF8EF3D3),
    NoteColor.rose => const Color(0xFFFFA4C4),
    NoteColor.sand => const Color(0xFFEDDB99),
  };

  /// Muted swatch used in the dark theme. Same hue, low saturation and
  /// lightness tuned so [NordSnowStorm.nord6] text stays above 4.5:1 contrast.
  Color get darkColor {
    if (this == NoteColor.none) return Colors.transparent;
    return HSLColor.fromColor(
      color,
    ).withSaturation(0.28).withLightness(0.31).toColor();
  }

  /// Swatch for the given [brightness].
  Color forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? darkColor : color;

  /// Legible foreground for content drawn on top of [forBrightness].
  Color onColorFor(Brightness brightness) => brightness == Brightness.dark
      ? NordSnowStorm.nord6
      : NordPolarNight.nord0;
}
