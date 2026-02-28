// MaterialApp entry point: wires theme, locale and navigator.
//
// Reads Settings from AppSettingsScope and maps them to MaterialApp
// parameters (ThemeMode, ThemeData, locale). The GlobalKey ensures
// Flutter Inspector works correctly across hot reloads.

import 'package:flutter/material.dart';
import 'package:qnotes/app/app_scaffold.dart';
import 'package:qnotes/app/app_settings_scope.dart';
import 'package:qnotes/app/media_query.dart';
import 'package:qnotes/bootstrap/remove_this_file.dart';

/// Entry point for the application that creates [MaterialApp].
class MaterialContext extends StatelessWidget {
  const MaterialContext({super.key});

  /// Global key required for correct Widgets Inspector behavior.
  static final _globalKey = GlobalKey(debugLabel: 'MaterialContext');

  @override
  Widget build(BuildContext context) {
    // TODO: Replace FakeSettings with real Settings from settings domain package.
    final settings = AppSettingsScope.of(context);
    final themeMode = settings.general.themeMode;
    final seedColor = settings.general.seedColor;
    final locale = settings.general.locale;

    // TODO: Replace FakeThemeModeVO with real ThemeModeVO from settings domain package.
    final materialThemeMode = switch (themeMode) {
      FakeThemeModeVO.system => ThemeMode.system,
      FakeThemeModeVO.light => ThemeMode.light,
      FakeThemeModeVO.dark => ThemeMode.dark,
    };

    return MaterialApp(
      themeMode: materialThemeMode,
      theme: ThemeData(
        colorSchemeSeed: seedColor,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: seedColor,
        brightness: Brightness.dark,
      ),
      locale: locale,
      home: const AppScaffold(),
      builder: (context, child) {
        return KeyedSubtree(
          key: _globalKey,
          child: MediaQueryRootOverride(child: child!),
        );
      },
    );
  }
}
