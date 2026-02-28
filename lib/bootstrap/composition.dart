// Assembly and initialization of all dependencies

import 'package:package_info_plus/package_info_plus.dart';
import 'package:qnotes/bootstrap/application_config.dart';
import 'package:qnotes/bootstrap/dependency_container.dart';
import 'package:qnotes/bootstrap/remove_this_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A place where Application-Wide dependencies are initialized.
///
/// Application-Wide dependencies are dependencies that have a global scope,
/// used in the entire application and have a lifetime that is the same as the application.
/// Composes dependencies and returns the result of composition.
Future<CompositionResult> composeDependencies({
  required ApplicationConfig config,
  required Logger logger,
  required ErrorReporter errorReporter,
}) async {
  final stopwatch = Stopwatch()..start();

  logger.info('Initializing dependencies...');

  final dependencies = await createDependenciesContainer(
    config,
    logger,
    errorReporter,
  );

  stopwatch.stop();
  logger.info(
    'Dependencies initialized successfully in ${stopwatch.elapsedMilliseconds} ms.',
  );

  return CompositionResult(
    dependencies: dependencies,
    millisecondsSpent: stopwatch.elapsedMilliseconds,
  );
}

final class CompositionResult {
  const CompositionResult({
    required this.dependencies,
    required this.millisecondsSpent,
  });

  final DependenciesContainer dependencies;
  final int millisecondsSpent;

  @override
  String toString() =>
      'CompositionResult('
      'dependencies: $dependencies, '
      'millisecondsSpent: $millisecondsSpent'
      ')';
}

/// Creates the initialized [DependenciesContainer].
Future<DependenciesContainer> createDependenciesContainer(
  ApplicationConfig config,
  Logger logger,
  ErrorReporter errorReporter,
) async {
  final sharedPreferences = SharedPreferencesAsync();
  final packageInfo = await PackageInfo.fromPlatform();

  // TODO: Replace with real SettingsContainer from settings feature package.
  final settingsContainer = await SettingsContainer.create(
    sharedPreferences: sharedPreferences,
  );

  return DependenciesContainer(
    logger: logger,
    config: config,
    errorReporter: errorReporter,
    packageInfo: packageInfo,
    settingsContainer: settingsContainer,
  );
}

/// TODO: Replace with real Logger creation using observers from packages/monitoring.
Logger createAppLogger({List<LogObserver> observers = const []}) {
  final logger = Logger();

  for (final observer in observers) {
    logger.addObserver(observer);
  }

  return logger;
}

/// TODO: Replace with real ErrorReporter initialization from packages/monitoring.
Future<ErrorReporter> createErrorReporter(ApplicationConfig config) async {
  final errorReporter = ErrorReporter();

  if (config.enableSentry) {
    await errorReporter.initialize();
  }

  return errorReporter;
}
