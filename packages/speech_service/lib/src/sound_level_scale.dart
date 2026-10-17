import 'package:flutter/foundation.dart' show TargetPlatform;

/// Maps raw platform sound levels onto `0.0..1.0`.
///
/// The platforms disagree on units: iOS reports decibels relative to full
/// scale (speech sits around −40..−10 dB), Android reports the recogniser's
/// RMS dB (roughly 0..10 while speaking). Values outside the range clamp.
final class SoundLevelScale {
  const SoundLevelScale({required this.silence, required this.loud})
    : assert(loud > silence, 'loud must be above silence');

  /// Raw value treated as silence (maps to 0).
  final double silence;

  /// Raw value treated as loud speech (maps to 1).
  final double loud;

  static const ios = SoundLevelScale(silence: -50, loud: -10);
  static const android = SoundLevelScale(silence: 0, loud: 10);

  static SoundLevelScale forPlatform(TargetPlatform platform) =>
      switch (platform) {
        TargetPlatform.iOS || TargetPlatform.macOS => ios,
        _ => android,
      };

  double normalize(double raw) =>
      ((raw - silence) / (loud - silence)).clamp(0.0, 1.0);
}
