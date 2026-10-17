import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';

/// Small uppercase label that separates groups of notes ("Pinned", "Others").
class NoteSectionHeader extends StatelessWidget {
  const NoteSectionHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.xSmall,
        Spacing.mediumLarge,
        Spacing.xSmall,
        Spacing.small,
      ),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
