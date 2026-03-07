import 'package:preferences_repository/preferences_repository.dart';
import 'package:flutter/widgets.dart';

/// Listens to [PreferencesService] and provides [Preferences] to the subtree.
class PreferencesScope extends StatelessWidget {
  const PreferencesScope({
    required this.service,
    required this.child,
    super.key,
  });

  final PreferencesService service;
  final Widget child;

  /// Returns current [Preferences] and subscribes to changes.
  static Preferences of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_PreferencesInherited>()!
      .preferences;

  /// Updates preferences without subscribing to changes.
  static Future<void> update(
    BuildContext context,
    Preferences Function(Preferences) transform,
  ) => context
      .getInheritedWidgetOfExactType<_PreferencesInherited>()!
      .service
      .update(transform);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Preferences>(
      stream: service.stream,
      initialData: service.current,
      builder: (context, snapshot) {
        return _PreferencesInherited(
          preferences: snapshot.data!,
          service: service,
          child: child,
        );
      },
    );
  }
}

class _PreferencesInherited extends InheritedWidget {
  const _PreferencesInherited({
    required super.child,
    required this.preferences,
    required this.service,
  });

  final Preferences preferences;
  final PreferencesService service;

  @override
  bool updateShouldNotify(_PreferencesInherited old) =>
      preferences != old.preferences;
}
