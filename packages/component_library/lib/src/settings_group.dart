import 'package:flutter/material.dart';

import 'theme/app_radius.dart';
import 'theme/spacing.dart';

/// Rounded surface that groups related rows of a settings-style sheet, with
/// hairlines between [children].
///
/// Pass [child] instead for content that lays out its own rows.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({this.children, this.child, super.key})
    : assert(children != null || child != null);

  final List<Widget>? children;
  final Widget? child;

  static const radius = Radius.circular(AppRadius.mediumLarge);

  /// Fill of the group; also used by rows that draw their own piece of it.
  static Color colorOf(ThemeData theme) => theme.brightness == Brightness.dark
      ? theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.6)
      : theme.colorScheme.surfaceContainerLow;

  /// Hairline between rows.
  static Widget divider(ColorScheme colorScheme) => Divider(
    indent: Spacing.mediumLarge,
    endIndent: Spacing.mediumLarge,
    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = children;
    // Material (not DecoratedBox) so ListTile and InkWell splashes stay visible.
    return Material(
      color: colorOf(theme),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child:
          child ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < rows!.length; i++) ...[
                if (i > 0) divider(theme.colorScheme),
                rows[i],
              ],
            ],
          ),
    );
  }
}
