// Flutter initialization, error zone setup, runApp launch

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qnotes/app/initialization_failed.dart';
import 'package:qnotes/app/root_context.dart';
import 'package:qnotes/bootstrap/app_bloc_observer.dart';
import 'package:qnotes/bootstrap/application_config.dart';
import 'package:qnotes/bootstrap/bloc_transformer.dart';
import 'package:qnotes/bootstrap/composition.dart';
import 'package:qnotes/bootstrap/remove_this_file.dart';

/// Initializes dependencies and runs app.
Future<void> starter() async {
  const config = ApplicationConfig();

  // TODO: Replace ErrorReporter with real implementation from packages/monitoring.
  final errorReporter = await createErrorReporter(config);

  // TODO: Replace Logger with real implementation from packages/monitoring.
  final logger = createAppLogger(
    observers: [
      ErrorReporterLogObserver(errorReporter),
      if (!kReleaseMode) const PrintingLogObserver(logLevel: LogLevel.trace),
    ],
  );

  await runZonedGuarded(
    () async {
      // Ensure Flutter is initialized.
      WidgetsFlutterBinding.ensureInitialized();

      // Configure global error interception.
      // TODO: Replace with real logFlutterError / logPlatformDispatcherError from packages/monitoring.
      FlutterError.onError = logger.logFlutterError;
      WidgetsBinding.instance.platformDispatcher.onError =
          logger.logPlatformDispatcherError;

      // Setup bloc observer and transformer.
      Bloc.observer = AppBlocObserver(logger);
      Bloc.transformer = SequentialBlocTransformer<Object?>().transform;

      Future<void> composeAndRun() async {
        try {
          final compositionResult = await composeDependencies(
            config: config,
            logger: logger,
            errorReporter: errorReporter,
          );

          runApp(RootContext(compositionResult: compositionResult));
        } on Object catch (e, stackTrace) {
          logger.error('Initialization failed', error: e, stackTrace: stackTrace);
          runApp(
            InitializationFailedApp(
              error: e,
              stackTrace: stackTrace,
              onRetryInitialization: composeAndRun,
            ),
          );
        }
      }

      // Launch the application.
      await composeAndRun();
    },
    // TODO: Replace with logger.logZoneError from packages/monitoring.
    logger.logZoneError,
  );
}
