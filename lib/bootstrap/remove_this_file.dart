// TODO: Delete this file when all packages are implemented.
// All classes below are temporary fakes — replace with real implementations from packages.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── packages/monitoring ──────────────────────────────────────────────────────

/// TODO: Replace with LogObserver from packages/monitoring package.
abstract class LogObserver {
  const LogObserver();
}

/// TODO: Replace with LogLevel from packages/monitoring package.
enum LogLevel { trace, debug, info, warning, error }

/// TODO: Replace with PrintingLogObserver from packages/monitoring package.
class PrintingLogObserver extends LogObserver {
  const PrintingLogObserver({required this.logLevel});

  final LogLevel logLevel;
}

/// TODO: Replace with ErrorReporterLogObserver from packages/monitoring package.
class ErrorReporterLogObserver extends LogObserver {
  const ErrorReporterLogObserver(this.errorReporter);

  final ErrorReporter errorReporter;
}

/// TODO: Replace with Logger from packages/monitoring package.
class Logger {
  final _observers = <LogObserver>[];

  void addObserver(LogObserver observer) => _observers.add(observer);

  void info(String message) => debugPrint('INFO: $message');

  void error(
    String message, {
    required Object error,
    required StackTrace stackTrace,
  }) => debugPrint('ERROR: $message | $error');

  /// TODO: Replace with logger.logFlutterError from packages/monitoring.
  void logFlutterError(FlutterErrorDetails details) =>
      debugPrint('FLUTTER_ERROR: ${details.exception}');

  /// TODO: Replace with logger.logPlatformDispatcherError from packages/monitoring.
  bool logPlatformDispatcherError(Object error, StackTrace stackTrace) {
    debugPrint('PLATFORM_ERROR: $error');
    return true;
  }

  /// TODO: Replace with logger.logZoneError from packages/monitoring.
  void logZoneError(Object error, StackTrace stackTrace) =>
      debugPrint('ZONE_ERROR: $error');
}

// ─── packages/monitoring (error_reporter) ─────────────────────────────────────

/// TODO: Replace with ErrorReporter from packages/monitoring package.
class ErrorReporter {
  /// TODO: Replace with real initialization (e.g. Sentry.init).
  Future<void> initialize() async {}
}

// ─── Settings ─────────────────────────────────────────────────────────────────

/// TODO: Replace with ThemeModeVO from settings domain package.
enum ThemeModeVO { system, light, dark }

/// TODO: Replace with GeneralSettings from settings domain package.
class GeneralSettings {
  const GeneralSettings({
    this.themeMode = ThemeModeVO.system,
    this.seedColor = Colors.blue,
    this.locale,
  });

  final ThemeModeVO themeMode;
  final Color seedColor;
  final Locale? locale;
}

/// TODO: Replace with Settings from settings domain package.
class Settings {
  const Settings({this.general = const GeneralSettings()});

  final GeneralSettings general;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Settings && other.general == general);

  @override
  int get hashCode => general.hashCode;
}

/// TODO: Replace with SettingsService from settings feature package.
class SettingsService {
  Settings _current = const Settings();
  final _controller = StreamController<Settings>.broadcast();

  Stream<Settings> get stream => _controller.stream;
  Settings get current => _current;

  Future<void> update(Settings Function(Settings) transform) async {
    _current = transform(_current);
    _controller.add(_current);
  }
}

/// TODO: Replace with SettingsContainer from settings feature package.
class SettingsContainer {
  const SettingsContainer({required this.settingsService});

  final SettingsService settingsService;

  /// TODO: Replace with real settings loading from SharedPreferences.
  static Future<SettingsContainer> create({
    required SharedPreferencesAsync sharedPreferences,
  }) async =>
      SettingsContainer(settingsService: SettingsService());
}

// ─── common_utils ─────────────────────────────────────────────────────────────

/// TODO: Replace with inhOf extension from common_utils package.
extension InheritedContextExtension on BuildContext {
  T inhOf<T extends InheritedWidget>({bool listen = true}) {
    final widget = listen
        ? dependOnInheritedWidgetOfExactType<T>()
        : getInheritedWidgetOfExactType<T>();
    assert(widget != null, '$T not found in context');
    return widget!;
  }
}
