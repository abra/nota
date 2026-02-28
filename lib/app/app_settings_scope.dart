// InheritedWidget — tracks style and theme changes, language, etc.

import 'package:flutter/widgets.dart';
import 'package:qnotes/app/dependency_scope.dart';
import 'package:qnotes/bootstrap/remove_this_file.dart';

/// A scope that provides [Settings] to the application.
///
/// Listens to [SettingsService.stream] and rebuilds descendant widgets
/// that depend on settings when theme, locale, or other preferences change.
class AppSettingsScope extends StatelessWidget {
  const AppSettingsScope({required this.child, super.key});

  final Widget child;

  /// Returns the current [Settings] from the nearest [AppSettingsScope] ancestor.
  // TODO: Replace Settings with real Settings from settings domain package.
  // TODO: Replace inhOf with real inhOf extension from common_utils package.
  static Settings of(BuildContext context, {bool listen = true}) =>
      context.inhOf<_SettingsInherited>(listen: listen).settings;

  /// Updates settings via [SettingsService].
  // TODO: Replace Settings with real Settings from settings domain package.
  static Future<void> update(
    BuildContext context,
    Settings Function(Settings) transform,
  ) async {
    final settingsService =
        DependenciesScope.of(context).settingsContainer.settingsService;
    await settingsService.update(transform);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real SettingsService from settings feature package.
    final settingsService =
        DependenciesScope.of(context).settingsContainer.settingsService;

    return StreamBuilder<Settings>(
      stream: settingsService.stream,
      initialData: settingsService.current,
      builder: (context, snapshot) {
        return _SettingsInherited(settings: snapshot.data!, child: child);
      },
    );
  }
}

class _SettingsInherited extends InheritedWidget {
  const _SettingsInherited({required super.child, required this.settings});

  final Settings settings;

  @override
  bool updateShouldNotify(_SettingsInherited oldWidget) =>
      settings != oldWidget.settings;
}
