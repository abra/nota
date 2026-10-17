import 'package:flutter/material.dart';

import 'theme/app_radius.dart';
import 'theme/icon_size.dart';
import 'theme/spacing.dart';

/// Shared metrics for the floating bars (note list bottom bar, editor
/// toolbar). One grid everywhere: 40 px controls inside an 8 px panel
/// padding, 24 px icons, 16 px screen margin.
abstract final class FloatingBar {
  static const double controlSize = 40;
  static const double height = controlSize + Spacing.small * 2;
  static const double margin = Spacing.mediumLarge;
  static const double iconSize = IconSize.large;

  /// Scroll clearance that keeps content visible above a bar at the bottom.
  static const double clearance = height + margin * 2;

  static const BorderRadius controlRadius = BorderRadius.all(
    Radius.circular(AppRadius.small),
  );

  static const ButtonStyle buttonStyle = ButtonStyle(
    fixedSize: WidgetStatePropertyAll(Size.square(controlSize)),
    minimumSize: WidgetStatePropertyAll(Size.square(controlSize)),
    padding: WidgetStatePropertyAll(EdgeInsets.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    iconSize: WidgetStatePropertyAll(iconSize),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: controlRadius),
    ),
  );
}

/// Square icon button on the [FloatingBar] grid.
///
/// [filled] renders the primary call to action; [active] highlights a toggle
/// whose panel is open. Pass either [icon] or a custom [child].
class FloatingBarButton extends StatelessWidget {
  const FloatingBarButton({
    required this.tooltip,
    required this.onPressed,
    this.icon,
    this.child,
    this.filled = false,
    this.active = false,
    super.key,
  }) : assert(icon != null || child != null, 'Provide an icon or a child');

  final String tooltip;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? child;
  final bool filled;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final glyph = child ?? Icon(icon);

    if (filled) {
      return IconButton.filled(
        tooltip: tooltip,
        style: FloatingBar.buttonStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(colorScheme.primary),
          foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimary),
        ),
        icon: glyph,
        onPressed: onPressed,
      );
    }

    return IconButton(
      tooltip: tooltip,
      isSelected: active,
      style: FloatingBar.buttonStyle.copyWith(
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? colorScheme.onSurfaceVariant.withValues(alpha: 0.35)
              : active
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        backgroundColor: WidgetStatePropertyAll(
          active ? colorScheme.primaryContainer : Colors.transparent,
        ),
      ),
      icon: glyph,
      onPressed: onPressed,
    );
  }
}

/// Thin vertical separator between control groups inside a floating bar.
class FloatingBarDivider extends StatelessWidget {
  const FloatingBarDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: Spacing.xLarge,
      child: VerticalDivider(width: Spacing.mediumLarge),
    );
  }
}
