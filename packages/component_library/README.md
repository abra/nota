# component_library

UI components and design system for qnotes.

---

## Theme

The theme system has two layers:

- **`AppThemeData`** — describes the color scheme and component styles
- **`AppTheme`** — InheritedWidget that provides the theme to the widget tree

### How it works

```
AppSettings.seedColor           ← stored in SharedPreferences
          ↓
AppSettingsScope.of(context)    ← read in material_context.dart
          ↓
LightAppThemeData(seedColor:)   ← built in material_context.dart
DarkAppThemeData(seedColor:)
          ↓
AppTheme(lightTheme:, darkTheme:, child: MaterialApp(...))
          ↓
MaterialApp(
  themeMode: settings.themeMode,
  theme: lightTheme.materialThemeData,
  darkTheme: darkTheme.materialThemeData,
)
          ↓
AppTheme.of(context)            ← available to any widget in the tree
```

`AppTheme.of(context)` automatically returns the light or dark theme based on
`Theme.of(context).brightness`, which is driven by `themeMode`.

### Reading the theme in a widget

```dart
import 'package:component_library/component_library.dart';

class NoteCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context); // light or dark, automatically

    return Card(
      color: theme.noteCardBackgroundColor,
    );
  }
}
```

### Adding custom colors for a new component

**Step 1** — Declare a getter in `AppThemeData`:

```dart
// lib/src/theme/app_theme_data.dart
abstract class AppThemeData {
  Color get noteCardBackgroundColor;
}
```

**Step 2** — Implement in `LightAppThemeData` and `DarkAppThemeData`:

```dart
final class LightAppThemeData extends AppThemeData {
  @override
  Color get noteCardBackgroundColor => Colors.white;
}

final class DarkAppThemeData extends AppThemeData {
  @override
  Color get noteCardBackgroundColor => Colors.grey.shade900;
}
```

**Step 3** — Use in your component via `AppTheme.of(context)`.

**Step 4** — Export from `lib/component_library.dart` if the component is new.

For the full guide with code examples see [.docs/THEMING.md](../../.docs/THEMING.md).

---

## Design tokens

### Spacing

| Constant              | Value |
|-----------------------|-------|
| `Spacing.xSmall`      | 4     |
| `Spacing.small`       | 8     |
| `Spacing.medium`      | 12    |
| `Spacing.mediumLarge` | 16    |
| `Spacing.large`       | 20    |
| `Spacing.xLarge`      | 24    |
| `Spacing.xxLarge`     | 48    |
| `Spacing.xxxLarge`    | 64    |

### FontSize

| Constant               | Value |
|------------------------|-------|
| `FontSize.small`       | 11    |
| `FontSize.medium`      | 14    |
| `FontSize.mediumLarge` | 18    |
| `FontSize.large`       | 22    |
| `FontSize.xLarge`      | 32    |
| `FontSize.xxLarge`     | 48    |

Use these constants instead of magic numbers:

```dart
padding: const EdgeInsets.all(Spacing.mediumLarge) // 16
fontSize: FontSize.medium // 14
```

---

## Package structure

```
lib/
  component_library.dart          ← barrel export
  src/
    theme/
      app_theme.dart              ← AppTheme (InheritedWidget)
      app_theme_data.dart         ← AppThemeData + LightAppThemeData + DarkAppThemeData
      spacing.dart                ← Spacing constants
      font_size.dart              ← FontSize constants
```
