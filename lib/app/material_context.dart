// MaterialApp entry point: wires theme, locale and navigator.
//
// Reads AppSettings from AppSettingsScope and builds AppThemeData instances
// from component_library. Wraps MaterialApp in AppTheme so that all widgets
// in the tree can access custom theme colors via AppTheme.of(context).

import 'package:app_settings/app_settings.dart';
import 'package:component_library/component_library.dart';
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

    final lightTheme = LightAppThemeData(seedColor: settings.seedColor);
    final darkTheme = DarkAppThemeData(seedColor: settings.seedColor);

    return AppTheme(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      child: MaterialApp(
        themeMode: settings.themeMode,
        theme: lightTheme.materialThemeData,
        darkTheme: darkTheme.materialThemeData,
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
      ),
    );
  }
}
