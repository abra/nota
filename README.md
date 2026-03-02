# qnotes

Simple note-taking app. Built on [flutter_starter](https://github.com/your-org/flutter_starter) — clean architecture, BLoC, modular feature packages.

## Requirements

- Flutter 3.29+
- Dart 3.7+

## Project structure

```
lib/
  main.dart                     — delegates to starter()
  bootstrap/
    starter.dart                — runZonedGuarded, error handling, runApp
    composition.dart            — composeDependencies() → CompositionResult
    application_config.dart     — compile-time constants via --dart-define
    environment.dart            — enum Environment (dev / staging / prod)
    app_bloc_observer.dart      — global BLoC logging
    bloc_transformer.dart       — SequentialBlocTransformer (asyncExpand)
    dependency_container.dart   — DependenciesContainer + TestDependenciesContainer
  app/
    root_context.dart           — DependenciesScope → MaterialContext
    dependency_scope.dart       — InheritedWidget for DependenciesContainer + AppSettingsScope
    material_context.dart       — MaterialApp wired to AppSettingsScope (theme, locale)
    media_query.dart            — clamps text scale factor at root
    initialization_failed.dart  — error screen with retry button
    routing.dart                — route name constants
  utils/
    inherited_extension.dart    — inhOf / inhMaybeOf helpers
    string_extension.dart       — String.limit(n) for log truncation
packages/
  features/
    app_settings/                 — theme mode, seed color, locale (SharedPreferences)
  component_library/            — shared UI: theme, design tokens, common widgets
  monitoring/                   — Logger, ErrorReportingService, AnalyticsReporter
```

## packages/features/app_settings

Manages user app_settings preferences: theme mode (light/dark/system), seed color, and locale.
Persists to SharedPreferences automatically.

```dart
// Read (subscribes to changes):
final app_settings = AppSettingsScope.of(context);
app_settings.themeMode  // ThemeMode
app_settings.seedColor  // Color
app_settings.locale     // Locale

// Update (persists immediately):
AppSettingsScope.update(context, (s) => s.copyWith(themeMode: ThemeMode.dark));
```

## Run

```bash
flutter pub get
flutter run
```

Expected startup logs:
```
[INF] Initializing dependencies...
[INF] Dependencies initialized successfully in N ms.
```
