// MaterialApp entry point: wires theme, locale and navigator.
//
// Reads AppSettings from AppSettingsScope and maps them to MaterialApp
// parameters (ThemeMode, ThemeData, locale). The GlobalKey ensures
// Flutter Inspector works correctly across hot reloads.

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:qnotes/app/media_query.dart';

/// Entry point for the application that creates [MaterialApp].
class MaterialContext extends StatelessWidget {
  const MaterialContext({super.key});

  /// Global key required for correct Widgets Inspector behavior.
  static final _globalKey = GlobalKey(debugLabel: 'MaterialContext');

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);

    return MaterialApp(
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorSchemeSeed: settings.seedColor,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: settings.seedColor,
        brightness: Brightness.dark,
      ),
      locale: settings.locale,
      home: const Placeholder(),
      // TODO: Replace with app entry screen
      builder: (context, child) {
        // KeyedSubtree with a stable GlobalKey prevents Flutter from
        // destroying and recreating the subtree when MaterialApp rebuilds,
        // which is required for correct Flutter Inspector behavior.
        return KeyedSubtree(
          key: _globalKey,
          child: MediaQueryRootOverride(child: child!),
        );
      },
    );
  }
}
