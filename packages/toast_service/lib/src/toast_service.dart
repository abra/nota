import 'package:component_library/component_library.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum NotificationType { success, error, info }

/// Optional inline action rendered at the trailing edge of a toast,
/// e.g. "Undo" after a delete.
final class ToastAction {
  const ToastAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// Shows a transient toast at the top of the screen.
///
/// Toasts with an [action] stay a little longer so the user has time to react.
void showToast(
  BuildContext context, {
  required NotificationType type,
  required String message,
  ToastAction? action,
}) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final accent = switch (type) {
    NotificationType.success => NordAurora.nord14,
    NotificationType.error => NordAurora.nord11,
    NotificationType.info => colorScheme.primary,
  };

  late final ToastificationItem item;
  item = toastification.show(
    context: context,
    type: switch (type) {
      NotificationType.success => ToastificationType.success,
      NotificationType.error => ToastificationType.error,
      NotificationType.info => ToastificationType.info,
    },
    style: ToastificationStyle.flat,
    alignment: Alignment.topCenter,
    autoCloseDuration: Duration(seconds: action == null ? 3 : 5),
    animationDuration: const Duration(milliseconds: 260),
    showProgressBar: false,
    closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
    closeOnClick: action == null,
    dragToClose: true,
    primaryColor: accent,
    backgroundColor: colorScheme.surfaceBright,
    foregroundColor: colorScheme.onSurface,
    borderSide: BorderSide.none,
    borderRadius: FloatingPanel.radius,
    boxShadow: FloatingPanel.shadows,
    margin: const EdgeInsets.symmetric(
      horizontal: Spacing.mediumLarge,
      vertical: Spacing.small,
    ),
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.medium,
      vertical: Spacing.small,
    ),
    title: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (action != null) ...[
          const SizedBox(width: Spacing.small),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: theme.textTheme.labelLarge,
            ),
            onPressed: () {
              toastification.dismiss(item);
              action.onPressed();
            },
            child: Text(action.label),
          ),
        ],
      ],
    ),
    animationBuilder: (context, animation, alignment, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.4),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
