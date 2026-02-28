// Responsive window size breakpoints and scope

import 'package:flutter/material.dart';

/// Breakpoints for responsive design following Material Design guidelines.
extension type const WindowSize(Size _size) implements Size {
  static const _medium = 600.0;
  static const _expanded = 840.0;
  static const _large = 1200.0;
  static const _extraLarge = 1600.0;

  bool get isCompact => maybeMap(orElse: () => false, compact: () => true);
  bool get isMedium => maybeMap(orElse: () => false, medium: () => true);
  bool get isMediumOrLarger =>
      maybeMap(orElse: () => true, compact: () => false);
  bool get isExpanded => maybeMap(orElse: () => false, expanded: () => true);
  bool get isExpandedOrLarger =>
      maybeMap(orElse: () => true, compact: () => false, medium: () => false);
  bool get isLarge => maybeMap(orElse: () => false, large: () => true);
  bool get isExtraLarge =>
      maybeMap(orElse: () => false, extraLarge: () => true);

  T map<T>({
    required T Function() compact,
    required T Function() medium,
    required T Function() expanded,
    required T Function() large,
    required T Function() extraLarge,
  }) => switch (_size.width) {
    < _medium => compact(),
    < _expanded => medium(),
    < _large => expanded(),
    < _extraLarge => large(),
    _ => extraLarge(),
  };

  T maybeMap<T>({
    required T Function() orElse,
    T Function()? compact,
    T Function()? medium,
    T Function()? expanded,
    T Function()? large,
    T Function()? extraLarge,
  }) => map(
    compact: compact ?? orElse,
    medium: medium ?? orElse,
    expanded: expanded ?? orElse,
    large: large ?? orElse,
    extraLarge: extraLarge ?? orElse,
  );
}

/// Provides [WindowSize] to the widget tree based on current [MediaQuery] size.
class WindowSizeScope extends StatelessWidget {
  const WindowSizeScope({required this.child, super.key});

  final Widget child;

  /// Returns the [WindowSize] from the nearest [WindowSizeScope] ancestor.
  static WindowSize of(BuildContext context, {bool listen = true}) {
    final windowSize = listen
        ? context
              .dependOnInheritedWidgetOfExactType<_InheritedWindowSize>()
              ?.windowSize
        : context
              .getInheritedWidgetOfExactType<_InheritedWindowSize>()
              ?.windowSize;

    assert(windowSize != null, 'WindowSizeScope not found in context');
    return windowSize!;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return _InheritedWindowSize(windowSize: WindowSize(size), child: child);
  }
}

class _InheritedWindowSize extends InheritedWidget {
  const _InheritedWindowSize({required this.windowSize, required super.child});

  final WindowSize windowSize;

  @override
  bool updateShouldNotify(_InheritedWindowSize oldWidget) =>
      windowSize != oldWidget.windowSize;
}
