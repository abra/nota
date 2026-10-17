import 'package:flutter/material.dart';

import 'theme/icon_size.dart';
import 'theme/spacing.dart';

/// Centered placeholder for an empty collection: a soft icon badge, a short
/// message and an optional hint explaining how to get started.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.message,
    this.hint,
    this.icon = Icons.sticky_note_2_outlined,
    super.key,
  });

  final String message;
  final String? hint;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xxLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(Spacing.large),
                child: Icon(
                  icon,
                  size: IconSize.xLarge + Spacing.xSmall,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: Spacing.large),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            if (hint != null) ...[
              const SizedBox(height: Spacing.small),
              Text(
                hint!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
