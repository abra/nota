// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "speech_apple",
  platforms: [.iOS("15.0")],
  products: [.library(name: "speech-apple", targets: ["speech_apple"])],
  dependencies: [],
  targets: [.target(name: "speech_apple", dependencies: [])]
)
