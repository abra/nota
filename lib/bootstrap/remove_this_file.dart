class Logger {
  void info(String temp) {
    print("info: $temp");
  }

  void error(
    String str, {
    required Object error,
    required StackTrace stackTrace,
  }) {
    print("error: $error, $stackTrace");
  }
}

class ErrorReporter {}

class SettingsContainer {}
