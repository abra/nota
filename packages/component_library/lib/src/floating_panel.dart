import 'package:flutter/material.dart';

import 'theme/app_radius.dart';
import 'theme/spacing.dart';

/// Rounded floating surface with a soft layered shadow.
///
/// Used for the bottom bars on the note list and the editor toolbar so every
/// floating control shares one elevation language. In the dark theme the
/// shadow is nearly invisible, so a hairline border provides the edge instead.
class FloatingPanel extends StatelessWidget {
  const FloatingPanel({
    required this.child,
    this.padding = const EdgeInsets.all(Spacing.small),
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Surface colour; defaults to [ColorScheme.surfaceBright].
  final Color? color;

  static const radius = BorderRadius.all(Radius.circular(AppRadius.large));

  static const shadows = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 18, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      // Transparent outer box so the shadow renders outside the clip below.
      decoration: const BoxDecoration(
        color: Color(0x00000000),
        borderRadius: radius,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color ?? theme.colorScheme.surfaceBright,
            borderRadius: radius,
            border: isDark
                ? Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.7,
                    ),
                  )
                : null,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
