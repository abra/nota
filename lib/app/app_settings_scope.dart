// InheritedWidget that propagates Settings down the widget tree.
//
// Subscribes to SettingsService.stream and rebuilds only the subtree
// that depends on settings when theme, locale or other preferences change.
// Widgets read settings via AppSettingsScope.of(context).

import 'package:flutter/widgets.dart';
import 'package:qnotes/app/dependency_scope.dart';
import 'package:qnotes/bootstrap/remove_this_file.dart';
import 'package:qnotes/utils/inherited_extension.dart';

/// A scope that provides [FakeSettings] to the application.
///
/// Listens to [FakeSettingsService.stream] and rebuilds descendant widgets
/// that depend on settings when theme, locale, or other preferences change.
class AppSettingsScope extends StatelessWidget {
  const AppSettingsScope({required this.child, super.key});

  final Widget child;

  /// Returns the current [FakeSettings] from the nearest [AppSettingsScope] ancestor.
  // TODO: Replace FakeSettings with real Settings from settings domain package.
  static FakeSettings of(BuildContext context, {bool listen = true}) =>
      context.inhOf<_SettingsInherited>(listen: listen).settings;

  /// Updates settings via [FakeSettingsService].
  // TODO: Replace FakeSettings with real Settings from settings domain package.
  static Future<void> update(
    BuildContext context,
    FakeSettings Function(FakeSettings) transform,
  ) async {
    final settingsService = DependenciesScope.of(
      context,
    ).settingsContainer.settingsService;
    await settingsService.update(transform);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real SettingsService from settings feature package.
    final settingsService = DependenciesScope.of(
      context,
    ).settingsContainer.settingsService;

    return StreamBuilder<FakeSettings>(
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

  final FakeSettings settings;

  @override
  bool updateShouldNotify(_SettingsInherited oldWidget) =>
      settings != oldWidget.settings;
}
