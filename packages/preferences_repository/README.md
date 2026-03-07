# preferences_repository

Manages user preferences: theme mode and locale.
Persists to SharedPreferences automatically and streams changes via `PreferencesService`.

---

## What's included

| Class                | Description                                                       |
|----------------------|-------------------------------------------------------------------|
| `Preferences`        | Immutable model: `ThemeMode`, `Locale`                            |
| `PreferencesService` | Loads from disk on startup, persists on update, streams changes   |

---

## Usage

### Read preferences

Preferences are provided to the widget tree via `PreferencesScope` (lives in `lib/app/`):

```dart
final prefs = PreferencesScope.of(context);

prefs.themeMode  // ThemeMode (light / dark / system)
prefs.locale     // Locale
```

### Update preferences

```dart
// Theme mode
PreferencesScope.update(context, (p) => p.copyWith(themeMode: ThemeMode.dark));

// Locale
PreferencesScope.update(context, (p) => p.copyWith(locale: const Locale('ru')));
```

Changes are persisted to SharedPreferences immediately and streamed to all widgets that
called `PreferencesScope.of(context)`.

---

## Wiring

`PreferencesService` is created in `composition.dart` and stored in
`DependenciesContainer`.
`PreferencesScope` (in `lib/app/`) is placed in `RootContext` and wraps the whole widget
tree.

```
DependenciesScope
  └─ PreferencesScope     ← StreamBuilder + InheritedWidget (lib/app/)
       └─ MaterialContext ← reads theme/locale, passes to MaterialApp
            └─ your app
```
