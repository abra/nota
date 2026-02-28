// Data class — DI graph form, list of all application dependencies

import 'package:package_info_plus/package_info_plus.dart';
import 'package:qnotes/bootstrap/application_config.dart';
import 'package:qnotes/bootstrap/remove_this_file.dart';

/// Container for global dependencies.
class DependenciesContainer {
  const DependenciesContainer({
    required this.logger,
    required this.config,
    required this.errorReporter,
    required this.packageInfo,
    // TODO: Replace with real SettingsContainer from settings feature package.
    required this.settingsContainer,
  });

  final Logger logger;
  final ApplicationConfig config;
  final ErrorReporter errorReporter;
  final PackageInfo packageInfo;
  // TODO: Replace with real SettingsContainer from settings feature package.
  final SettingsContainer settingsContainer;
}

/// A special version of [DependenciesContainer] that is used in tests.
///
/// In order to use [DependenciesContainer] in tests, it is needed to
/// extend this class and provide the dependencies that are needed for the test.
base class TestDependenciesContainer implements DependenciesContainer {
  const TestDependenciesContainer();

  @override
  Object noSuchMethod(Invocation invocation) {
    throw UnimplementedError(
      'The test tries to access ${invocation.memberName} dependency, but '
      'it was not provided. Please provide the dependency in the test. '
      'You can do it by extending this class and providing the dependency.',
    );
  }
}
