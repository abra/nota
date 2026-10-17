// Host-side driver for `flutter drive`: saves every screenshot taken by the
// integration test into NOTA_SCREENSHOT_DIR (default: build/screenshots).
//
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/screenshot_tour_test.dart -d <device> \
//     --dart-define=NOTA_DRIVER=true

import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final dir =
        Platform.environment['NOTA_SCREENSHOT_DIR'] ?? 'build/screenshots';
    final file = File('$dir/$name.png')..createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    stdout.writeln('screenshot: ${file.path}');
    return true;
  },
);
