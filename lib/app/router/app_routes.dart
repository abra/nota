// Named route constants for the application.
//
// Centralizes route strings so that Navigator calls and deep-link handlers
// reference the same values instead of raw string literals.

/// Named route constants for the application.
///
/// Used with [Navigator] or a router package (e.g. go_router).
abstract final class AppRoutes {
  static const notes = '/';
  static const settings = '/settings';
}
