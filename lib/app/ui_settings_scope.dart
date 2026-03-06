import 'package:flutter/widgets.dart';
import 'package:ui_settings/ui_settings.dart';

/// Listens to [UiSettingsService] and provides [UiSettings] to the subtree.
class UiSettingsScope extends StatelessWidget {
  const UiSettingsScope({
    required this.service,
    required this.child,
    super.key,
  });

  final UiSettingsService service;
  final Widget child;

  /// Returns current [UiSettings] and subscribes to changes.
  static UiSettings of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_UiSettingsInherited>()!
      .settings;

  /// Updates settings without subscribing to changes.
  static Future<void> update(
    BuildContext context,
    UiSettings Function(UiSettings) transform,
  ) => context
      .getInheritedWidgetOfExactType<_UiSettingsInherited>()!
      .service
      .update(transform);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UiSettings>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        return _UiSettingsInherited(
          settings: snapshot.data!,
          service: service,
          child: child,
        );
      },
    );
  }
}

class _UiSettingsInherited extends InheritedWidget {
  const _UiSettingsInherited({
    required super.child,
    required this.settings,
    required this.service,
  });

  final UiSettings settings;
  final UiSettingsService service;

  @override
  bool updateShouldNotify(_UiSettingsInherited old) => settings != old.settings;
}
