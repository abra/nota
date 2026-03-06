// MaterialApp entry point: wires theme, locale and navigator.
//
// Reads AppSettings from AppSettingsScope and builds AppThemeData instances
// from component_library. Wraps MaterialApp in AppTheme so that all widgets
// in the tree can access custom theme colors via AppTheme.of(context).

import 'package:app_settings/app_settings.dart';
import 'package:component_library/component_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nota/app/screens/playground_screen.dart';

/// Entry point for the application that creates [MaterialApp].
class MaterialContext extends StatelessWidget {
  const MaterialContext({super.key});

  /// Global key required for correct Widgets Inspector behavior.
  static final _globalKey = GlobalKey(debugLabel: 'MaterialContext');

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);

    const lightTheme = LightAppThemeData();
    const darkTheme = DarkAppThemeData();

    return AppTheme(
      lightTheme: lightTheme,
      darkTheme: darkTheme,
      child: MaterialApp(
        themeMode: settings.themeMode,
        theme: lightTheme.materialThemeData,
        darkTheme: darkTheme.materialThemeData,
        locale: settings.locale,
        supportedLocales: const [Locale('en'), Locale('ru')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: kReleaseMode ? const Placeholder() : const PlaygroundScreen(),
        builder: (context, child) {
          // KeyedSubtree with a stable GlobalKey prevents Flutter from
          // destroying and recreating the subtree when MaterialApp rebuilds,
          // which is required for correct Flutter Inspector behavior.
          return KeyedSubtree(
            key: _globalKey,
            child: _MediaQueryRootOverride(child: child!),
          );
        },
      ),
    );
  }
}

// Clamps system text scale so large accessibility font sizes don't break layouts.
class _MediaQueryRootOverride extends StatelessWidget {
  const _MediaQueryRootOverride({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      MediaQuery.withClampedTextScaling(maxScaleFactor: 2, child: child);
}
