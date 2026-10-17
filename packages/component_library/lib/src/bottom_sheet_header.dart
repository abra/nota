import 'package:flutter/material.dart';

import 'theme/spacing.dart';

/// Title row for a bottom sheet with a trailing close button.
///
/// The close button is nudged right by its own padding so the glyph lines up
/// with the sheet's content edge while the title stays flush left.
class BottomSheetHeader extends StatelessWidget {
  const BottomSheetHeader({
    required this.title,
    required this.onClose,
    super.key,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Transform.translate(
          offset: const Offset(Spacing.small, 0),
          child: IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ),
      ],
    );
  }
}
