import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Lets Dart open this app's page in Settings; see AppSettingsOpener.
  /// Kept in this file because extra Swift sources would need the Xcode
  /// project, which is regenerated rather than versioned.
  private static let appSettingsChannel = "io.github.abra.nota/app_settings"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    registerAppSettingsChannel(with: engineBridge.pluginRegistry)
  }

  private func registerAppSettingsChannel(with registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "NotaAppSettings") else { return }
    let channel = FlutterMethodChannel(
      name: Self.appSettingsChannel,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "open" else {
        result(FlutterMethodNotImplemented)
        return
      }
      result(nil)
      Task { @MainActor in
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      }
    }
  }
}
