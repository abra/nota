# toast_service

Thin wrapper over [toastification](https://pub.dev/packages/toastification) for in-app
notifications.

## Why this package exists

Feature packages (`note_list`, `note_details`, etc.) should not depend directly on
`toastification`. By routing all toast calls through this package, the underlying library
can be swapped out in one place without touching any feature code.

## API

```dart
// Show a toast
showToast(
  context,
  type: NotificationType.success,
  message: 'Note deleted',
);

// Show a toast with an inline action (stays a little longer)
showToast(
  context,
  type: NotificationType.success,
  message: 'Note deleted',
  action: ToastAction(label: 'Undo', onPressed: restore),
);

// Wrap the widget tree (in MaterialContext)
ToastWrapper(child: child)
```

`NotificationType` has three values: `success`, `error` and `info`. Toasts use
the app theme (surface, shadows and corner radius from `component_library`).

## Swapping the library

All implementation details live in `lib/src/`. To replace `toastification`:

1. Update `pubspec.yaml` — remove `toastification`, add the new library.
2. Rewrite `toast_service.dart` and `toast_wrapper.dart` using the new library's API.
3. Feature packages and the app shell are unaffected.
