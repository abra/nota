# app_settings

Manages user preferences: theme mode, seed color, and locale.
Persists to SharedPreferences automatically. Streams changes to the widget tree via `AppSettingsScope`.

---

## What's included

| Class | Description |
|---|---|
| `AppSettings` | Immutable model: `ThemeMode`, `Color`, `Locale` |
| `AppSettingsService` | Loads from disk on startup, persists on update, streams changes |
| `AppSettingsScope` | `StreamBuilder` + `InheritedWidget` — provides settings to the widget tree |

---

## Usage

### Read settings

```dart
final settings = AppSettingsScope.of(context);

settings.themeMode  // ThemeMode (light / dark / system)
settings.seedColor  // Color
settings.locale     // Locale
```

### Update settings

```dart
// Theme mode
AppSettingsScope.update(context, (s) => s.copyWith(themeMode: ThemeMode.dark));

// Seed color
AppSettingsScope.update(context, (s) => s.copyWith(seedColor: Colors.teal));

// Locale
AppSettingsScope.update(context, (s) => s.copyWith(locale: const Locale('ru')));
```

Changes are persisted to SharedPreferences immediately and streamed to all widgets that called `AppSettingsScope.of(context)`.

---

## Wiring

`AppSettingsService` is created in `composition.dart` and stored in `DependenciesContainer`.
`DependenciesScope` automatically wraps the widget tree in `AppSettingsScope` — no manual placement needed.

```
DependenciesScope
  └─ AppSettingsScope       ← streams AppSettings
       └─ MaterialContext   ← reads theme/locale, passes to MaterialApp
            └─ your app
```
