# component_library

UI components and design system for Nota.

---

## Theme

The theme system has two layers:

- **`AppThemeData`** — describes the color scheme and component styles
- **`AppTheme`** — InheritedWidget that provides the theme to the widget tree

### How it works

```
PreferencesScope.of(context)    ← reads themeMode + locale (lib/app/)
          ↓
material_context.dart
  const LightAppThemeData()     ← built once, stateless
  const DarkAppThemeData()
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

### IconSize

| Constant          | Value |
|-------------------|-------|
| `IconSize.xSmall` | 14    |
| `IconSize.small`  | 18    |
| `IconSize.medium` | 20    |
| `IconSize.large`  | 24    |
| `IconSize.xLarge` | 28    |

### AppRadius

| Constant           | Value |
|--------------------|-------|
| `AppRadius.xSmall` | 2     |
| `AppRadius.small`  | 12    |
| `AppRadius.medium` | 14    |
| `AppRadius.large`  | 20    |

Use these constants instead of magic numbers:

```dart
padding: const EdgeInsets.all(Spacing.mediumLarge) // 16
fontSize: FontSize.medium // 14
icon: Icon(Icons.close, size: IconSize.medium) // 20
borderRadius: BorderRadius.circular(AppRadius.small) // 12
```

---

## Widgets

### BottomSheetHeader

Title + close button row for bottom sheets. Used in preferences menu and color picker.

```dart
BottomSheetHeader(
  title: 'Note color',
  onClose: () => Navigator.of(context).pop(),
)
```

### FadeGradientOverlay

Gradient fade pinned to the bottom of a `Stack`. Fades from transparent to scaffold
background, sits above scrollable content without blocking taps. Wraps itself in
`Positioned` + `IgnorePointer`.

```dart
Stack(
  children: [
    // scrollable content...
    FadeGradientOverlay(height: 80),
    // toolbar...
  ],
)
```

### CenteredCircularProgressIndicator

`CircularProgressIndicator` wrapped in `Center`.

```dart
const CenteredCircularProgressIndicator()
```

### EmptyState

Centered placeholder with an icon badge, a message and an optional hint.

```dart
EmptyState(message: l10n.emptyState, hint: l10n.emptyStateHint)
EmptyState(icon: Icons.search_off_rounded, message: l10n.noResults)
```

### ErrorState

```dart
ErrorState(
  message: l10n.loadFailed,
  retryLabel: l10n.retry,
  onRetry: () => bloc.add(Started()),
)
```

### FloatingPanel

Rounded floating surface with a soft layered shadow (hairline border in the
dark theme). Every floating control in the app sits on one of these.

```dart
FloatingPanel(child: Row(children: [...]))
```

### FloatingBar, FloatingBarButton, FloatingBarDivider

`FloatingBar` holds the shared metrics for floating bars: 40 px controls in an
8 px panel padding (56 px tall), 24 px icons, 16 px screen margin and the scroll
`clearance` to keep content visible above a bar. `FloatingBarButton` is the
square icon button on that grid (`filled` for the primary action, `active` for
an open toggle); `FloatingBarDivider` separates control groups.

```dart
FloatingPanel(
  child: Row(
    children: [
      FloatingBarButton(icon: Icons.close, tooltip: l10n.cancel, onPressed: onCancel),
      const FloatingBarDivider(),
      FloatingBarButton(icon: Icons.add, tooltip: l10n.addNote, filled: true, onPressed: onAdd),
    ],
  ),
)
```

## Package structure

```
lib/
  component_library.dart          ← barrel export
  src/
    bottom_sheet_header.dart      ← BottomSheetHeader widget
    centered_circular_progress_indicator.dart
    empty_state.dart              ← EmptyState widget
    error_state.dart              ← ErrorState widget
    fade_gradient_overlay.dart    ← FadeGradientOverlay widget
    floating_bar.dart             ← FloatingBar metrics, FloatingBarButton, FloatingBarDivider
    floating_panel.dart           ← FloatingPanel widget
    nota_logo.dart                ← NotaLogo widget
    theme/
      app_radius.dart             ← AppRadius constants
      app_theme.dart              ← AppTheme (InheritedWidget)
      app_theme_data.dart         ← AppThemeData + LightAppThemeData + DarkAppThemeData
      font_size.dart              ← FontSize constants
      icon_size.dart              ← IconSize constants
      note_color_x.dart           ← NoteColor → Color extension
      spacing.dart                ← Spacing constants
```
