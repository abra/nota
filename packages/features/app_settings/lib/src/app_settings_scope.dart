import 'package:app_settings/src/app_settings.dart';
import 'package:app_settings/src/app_settings_service.dart';
import 'package:flutter/widgets.dart';

/// Provides [AppSettings] to the widget subtree and rebuilds
/// dependants whenever settings change.
class AppSettingsScope extends StatelessWidget {
  const AppSettingsScope({
    required this.service,
    required this.child,
    super.key,
  });

  final AppSettingsService service;
  final Widget child;

  /// Returns current [AppSettings] and subscribes to changes.
  static AppSettings of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_AppSettingsInherited>()!
          .settings;

  /// Updates settings without subscribing to changes.
  static Future<void> update(
    BuildContext context,
    AppSettings Function(AppSettings) transform,
  ) => context
      .getInheritedWidgetOfExactType<_AppSettingsInherited>()!
      .service
      .update(transform);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettings>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        return _AppSettingsInherited(
          settings: snapshot.data!,
          service: service,
          child: child,
        );
      },
    );
  }
}

class _AppSettingsInherited extends InheritedWidget {
  const _AppSettingsInherited({
    required super.child,
    required this.settings,
    required this.service,
  });

  final AppSettings settings;
  final AppSettingsService service;

  @override
  bool updateShouldNotify(_AppSettingsInherited old) =>
      settings != old.settings;
}
