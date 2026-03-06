import 'package:app_settings_repository/app_settings_repository.dart';
import 'package:flutter/widgets.dart';

/// Listens to [AppSettingsService] and provides [AppSettings] to the subtree.
class AppSettingsScope extends StatelessWidget {
  const AppSettingsScope({
    required this.service,
    required this.child,
    super.key,
  });

  final AppSettingsService service;
  final Widget child;

  /// Returns current [AppSettings] and subscribes to changes.
  static AppSettings of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SettingsInherited>()!
      .settings;

  /// Updates settings without subscribing to changes.
  static Future<void> update(
    BuildContext context,
    AppSettings Function(AppSettings) transform,
  ) =>
      context
          .getInheritedWidgetOfExactType<_SettingsInherited>()!
          .service
          .update(transform);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppSettings>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        return _SettingsInherited(
          settings: snapshot.data!,
          service: service,
          child: child,
        );
      },
    );
  }
}

class _SettingsInherited extends InheritedWidget {
  const _SettingsInherited({
    required super.child,
    required this.settings,
    required this.service,
  });

  final AppSettings settings;
  final AppSettingsService service;

  @override
  bool updateShouldNotify(_SettingsInherited old) => settings != old.settings;
}
