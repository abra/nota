# app_settings_repository

Manages user preferences: theme mode and locale.
Persists to SharedPreferences automatically and streams changes via `AppSettingsService`.

---

## What's included

| Class                | Description                                                     |
|----------------------|-----------------------------------------------------------------|
| `AppSettings`        | Immutable model: `ThemeMode`, `Locale`                          |
| `AppSettingsService` | Loads from disk on startup, persists on update, streams changes |

---

## Usage

### Read settings

Settings are provided to the widget tree via `AppSettingsScope` (lives in `lib/app/`):

```dart
final settings = AppSettingsScope.of(context);

settings.themeMode  // ThemeMode (light / dark / system)
settings.locale     // Locale
```

### Update settings

```dart
// Theme mode
AppSettingsScope.update(context, (s) => s.copyWith(themeMode: ThemeMode.dark));

// Locale
AppSettingsScope.update(context, (s) => s.copyWith(locale: const Locale('ru')));
```

Changes are persisted to SharedPreferences immediately and streamed to all widgets that
called `AppSettingsScope.of(context)`.

---

## Wiring

`AppSettingsService` is created in `composition.dart` and stored in
`DependenciesContainer`.
`AppSettingsScope` (in `lib/app/`) is placed in `RootContext` and wraps the whole widget
tree.

```
DependenciesScope
  └─ AppSettingsScope     ← StreamBuilder + InheritedWidget (lib/app/)
       └─ MaterialContext ← reads theme/locale, passes to MaterialApp
            └─ your app
```
