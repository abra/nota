// Opens this app's page in the system settings.
//
// Implemented as a small method channel in the iOS and Android runners
// (AppDelegate.swift, MainActivity.kt) instead of a plugin: the only job is
// one intent / one URL, and the available plugins lag behind the Swift
// concurrency checks of current Xcode releases.

import 'package:flutter/services.dart';

abstract final class AppSettingsOpener {
  static const _channel = MethodChannel('io.github.abra.nota/app_settings');

  /// Opens the settings page where permissions can be granted. Failures are
  /// swallowed: the page is a convenience, and the panel already explains
  /// what to do by hand.
  static Future<void> open() async {
    try {
      await _channel.invokeMethod<void>('open');
    } on PlatformException {
      // The platform could not show the page; nothing to recover.
    } on MissingPluginException {
      // Not implemented on this platform (tests, desktop).
    }
  }
}
