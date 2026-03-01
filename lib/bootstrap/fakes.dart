// TODO: Delete this file when all packages are implemented.
// All classes below are temporary fakes — replace with real implementations from packages.

import 'dart:async';
import 'dart:ui' show Color, Locale;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── packages/monitoring (logger) ─────────────────────────────────────────────

/// TODO: Replace with LogMessage from packages/monitoring package.
class FakeLogMessage {
  const FakeLogMessage({
    required this.message,
    required this.level,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  final String message;
  final FakeLogLevel level;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
}

/// TODO: Replace with LogLevel from packages/monitoring package.
enum FakeLogLevel implements Comparable<FakeLogLevel> {
  trace._(),
  debug._(),
  info._(),
  warn._(),
  error._(),
  fatal._();

  const FakeLogLevel._();

  @override
  int compareTo(FakeLogLevel other) => index - other.index;
}

/// TODO: Replace with LogObserver from packages/monitoring package.
mixin FakeLogObserver {
  void onLog(FakeLogMessage logMessage);
}

/// TODO: Replace with PrintingLogObserver from packages/monitoring package.
final class FakePrintingLogObserver with FakeLogObserver {
  const FakePrintingLogObserver({required this.logLevel});

  final FakeLogLevel logLevel;

  @override
  void onLog(FakeLogMessage logMessage) {
    if (logMessage.level.index >= logLevel.index) {
      debugPrint(
        '[${logMessage.level.name.toUpperCase()}] ${logMessage.message}'
        '${logMessage.error != null ? '\n${logMessage.error}' : ''}',
      );
    }
  }
}

/// TODO: Replace with ErrorReporterLogObserver from packages/monitoring package.
final class FakeErrorReporterLogObserver with FakeLogObserver {
  const FakeErrorReporterLogObserver(this._errorReporter);

  final FakeErrorReporter _errorReporter;

  @override
  void onLog(FakeLogMessage logMessage) {
    if (!_errorReporter.isInitialized) return;

    if (logMessage.level.index >= FakeLogLevel.error.index) {
      _errorReporter.captureException(
        throwable: logMessage.error ?? logMessage.message,
        stackTrace: logMessage.stackTrace,
      );
    }
  }
}

/// TODO: Replace with Logger from packages/monitoring package.
base class FakeLogger {
  FakeLogger({List<FakeLogObserver>? observers}) {
    _observers.addAll(observers ?? []);
  }

  final _observers = <FakeLogObserver>{};

  void addObserver(FakeLogObserver observer) => _observers.add(observer);

  void removeObserver(FakeLogObserver observer) => _observers.remove(observer);

  void trace(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, FakeLogLevel.trace, error, stackTrace);

  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, FakeLogLevel.debug, error, stackTrace);

  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, FakeLogLevel.info, error, stackTrace);

  void warn(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, FakeLogLevel.warn, error, stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, FakeLogLevel.error, error, stackTrace);

  void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, FakeLogLevel.fatal, error, stackTrace);

  void _log(
    String message,
    FakeLogLevel level,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final logMessage = FakeLogMessage(
      message: message,
      level: level,
      timestamp: DateTime.now(),
      error: error,
      stackTrace: stackTrace,
    );
    for (final observer in _observers) {
      observer.onLog(logMessage);
    }
  }

  /// TODO: Replace with logger.logFlutterError from packages/monitoring.
  void logFlutterError(FlutterErrorDetails details) => error(
    'Flutter Error',
    error: details.exception,
    stackTrace: details.stack,
  );

  /// TODO: Replace with logger.logPlatformDispatcherError from packages/monitoring.
  bool logPlatformDispatcherError(Object error, StackTrace stackTrace) {
    this.error('Platform Error', error: error, stackTrace: stackTrace);
    return true;
  }

  /// TODO: Replace with logger.logZoneError from packages/monitoring.
  void logZoneError(Object error, StackTrace stackTrace) =>
      this.error('Zone Error', error: error, stackTrace: stackTrace);
}

// ─── packages/monitoring (error_reporter) ─────────────────────────────────────

/// TODO: Replace with ErrorReporter from packages/monitoring package.
abstract interface class FakeErrorReporter {
  bool get isInitialized;

  /// TODO: Replace with real initialization (e.g. Sentry.init).
  Future<void> initialize();

  Future<void> close();

  Future<void> captureException({
    required Object throwable,
    StackTrace? stackTrace,
  });
}

/// TODO: Replace with concrete ErrorReporter implementation from packages/monitoring.
final class FakeNoopErrorReporter implements FakeErrorReporter {
  const FakeNoopErrorReporter();

  @override
  bool get isInitialized => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> close() async {}

  @override
  Future<void> captureException({
    required Object throwable,
    StackTrace? stackTrace,
  }) async {}
}

// ─── packages/features/settings ───────────────────────────────────────────────

/// TODO: Replace with ThemeModeVO from packages/features/settings.
enum FakeThemeModeVO { light, dark, system }

/// TODO: Replace with GeneralSettings from packages/features/settings.
final class FakeGeneralSettings {
  const FakeGeneralSettings({
    this.locale = const Locale('en'),
    this.themeMode = FakeThemeModeVO.system,
    this.seedColor = const Color(0xFF6200EE),
  });

  final FakeThemeModeVO themeMode;
  final Color seedColor;
  final Locale locale;

  FakeGeneralSettings copyWith({
    FakeThemeModeVO? themeMode,
    Color? seedColor,
    Locale? locale,
  }) => FakeGeneralSettings(
    themeMode: themeMode ?? this.themeMode,
    seedColor: seedColor ?? this.seedColor,
    locale: locale ?? this.locale,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FakeGeneralSettings &&
          seedColor == other.seedColor &&
          themeMode == other.themeMode &&
          locale == other.locale;

  @override
  int get hashCode => Object.hash(seedColor, themeMode, locale);
}

/// TODO: Replace with Settings from packages/features/settings.
class FakeSettings {
  const FakeSettings({this.general = const FakeGeneralSettings()});

  final FakeGeneralSettings general;

  FakeSettings copyWith({FakeGeneralSettings? general}) =>
      FakeSettings(general: general ?? this.general);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FakeSettings && other.general == general);

  @override
  int get hashCode => general.hashCode;
}

/// TODO: Replace with SettingsService from packages/features/settings.
class FakeSettingsService {
  FakeSettings _current = const FakeSettings();
  final _controller = StreamController<FakeSettings>.broadcast();

  Stream<FakeSettings> get stream => _controller.stream;

  FakeSettings get current => _current;

  Future<void> update(FakeSettings Function(FakeSettings) transform) async {
    _current = transform(_current);
    _controller.add(_current);
  }

  Future<void> dispose() => _controller.close();
}

/// TODO: Replace with SettingsContainer from packages/features/settings.
class FakeSettingsContainer {
  const FakeSettingsContainer({required this.settingsService});

  final FakeSettingsService settingsService;

  /// TODO: Replace with real settings loading from SharedPreferences.
  static Future<FakeSettingsContainer> create({
    required SharedPreferencesAsync sharedPreferences,
  }) async =>
      FakeSettingsContainer(settingsService: FakeSettingsService());
}
