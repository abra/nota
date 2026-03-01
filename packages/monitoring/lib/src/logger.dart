// Logger base class with observer pattern.
//
// Extend Logger to add custom behaviour (e.g. remote logging).
// Attach LogObserver implementations to receive log messages.

import 'package:flutter/foundation.dart';

/// A single log message produced by [Logger].
class LogMessage {
  const LogMessage({
    required this.message,
    required this.level,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  final String message;
  final LogLevel level;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
}

/// Severity level of a [LogMessage].
enum LogLevel implements Comparable<LogLevel> {
  trace._(),
  debug._(),
  info._(),
  warn._(),
  error._(),
  fatal._();

  const LogLevel._();

  @override
  int compareTo(LogLevel other) => index - other.index;

  /// Short uppercase label used in log output (e.g. TRC, INF, ERR).
  String toShortName() => switch (this) {
    LogLevel.trace => 'TRC',
    LogLevel.debug => 'DBG',
    LogLevel.info  => 'INF',
    LogLevel.warn  => 'WRN',
    LogLevel.error => 'ERR',
    LogLevel.fatal => 'FTL',
  };
}

/// Observer notified on every [LogMessage] produced by a [Logger].
mixin LogObserver {
  void onLog(LogMessage logMessage);
}

/// Base logger. Dispatches messages to attached [LogObserver]s.
///
/// Extend this class to customise behaviour (e.g. add context fields).
/// Use [addObserver] / [removeObserver] to attach output sinks.
base class Logger {
  Logger({List<LogObserver>? observers}) {
    _observers.addAll(observers ?? []);
  }

  final _observers = <LogObserver>{};

  void addObserver(LogObserver observer) => _observers.add(observer);

  void removeObserver(LogObserver observer) => _observers.remove(observer);

  void trace(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.trace, error, stackTrace);

  void debug(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.debug, error, stackTrace);

  void info(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.info, error, stackTrace);

  void warn(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.warn, error, stackTrace);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.error, error, stackTrace);

  void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(message, LogLevel.fatal, error, stackTrace);

  void _log(
    String message,
    LogLevel level,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final logMessage = LogMessage(
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

  void logFlutterError(FlutterErrorDetails details) => error(
    'Flutter Error',
    error: details.exception,
    stackTrace: details.stack,
  );

  bool logPlatformDispatcherError(Object error, StackTrace stackTrace) {
    this.error('Platform Error', error: error, stackTrace: stackTrace);
    return true;
  }

  void logZoneError(Object error, StackTrace stackTrace) =>
      this.error('Zone Error', error: error, stackTrace: stackTrace);

  /// Releases all observers. Call when the logger is no longer needed.
  Future<void> destroy() async => _observers.clear();
}
