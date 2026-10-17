import AVFoundation
import Flutter
import Speech

/// Continuous on-device dictation through SpeechAnalyzer (iOS 26+).
///
/// Method channel: `isSupported`, `requestPermissions`, `supportedLocales`,
/// `start {localeId, segmentPauseMs}`, `setSegmentPause {segmentPauseMs}`,
/// `stop`. Event channel payloads are maps with a `type` of `transcript`
/// (`text`, `isFinal`), `level` (`decibels`) or `error` (`code`, `message`).
///
/// Unlike SFSpeechRecognizer, SpeechAnalyzer has no one-minute limit and
/// keeps one session alive; the Dart side still sees utterances because the
/// plugin asks the analyzer to finalize after `segmentPause` of silence.
public class SpeechApplePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private static let methodChannelName = "io.github.abra.nota/speech_apple"
  private static let eventChannelName = "io.github.abra.nota/speech_apple/events"

  private var eventSink: FlutterEventSink?
  /// Typed as `Any` so the class compiles below iOS 26; see `session`.
  private var sessionBox: Any?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = SpeechApplePlugin()
    let methods = FlutterMethodChannel(
      name: methodChannelName, binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: methods)
    let events = FlutterEventChannel(
      name: eventChannelName, binaryMessenger: registrar.messenger())
    events.setStreamHandler(instance)
  }

  // MARK: - FlutterStreamHandler

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  // MARK: - Method channel

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(iOS 26.0, *) else {
      switch call.method {
      case "isSupported": result(false)
      case "supportedLocales": result([String]())
      case "stop": result(nil)
      default:
        result(FlutterError(code: "unsupported", message: "SpeechAnalyzer needs iOS 26", details: nil))
      }
      return
    }
    switch call.method {
    case "isSupported":
      result(true)
    case "requestPermissions":
      Task {
        let granted = await AVAudioApplication.requestRecordPermission()
        await MainActor.run { result(granted) }
      }
    case "supportedLocales":
      Task {
        let locales = await SpeechTranscriber.supportedLocales
        let ids = locales.map { $0.identifier(.bcp47) }
        await MainActor.run { result(ids) }
      }
    case "start":
      guard let args = call.arguments as? [String: Any],
        let localeId = args["localeId"] as? String,
        let pauseMs = args["segmentPauseMs"] as? Int
      else {
        result(FlutterError(code: "arguments", message: "localeId and segmentPauseMs required", details: nil))
        return
      }
      let emit = makeEmitter()
      Task {
        if let previous = self.session { await previous.stop() }
        let session = DictationSession(segmentPause: .milliseconds(pauseMs), emit: emit)
        await MainActor.run { self.sessionBox = session }
        do {
          let locale = localeId.isEmpty ? Locale.current : Locale(identifier: localeId)
          try await session.start(locale: locale)
          await MainActor.run { result(nil) }
        } catch let error as DictationError {
          await session.stop()
          await MainActor.run {
            self.sessionBox = nil
            result(FlutterError(code: error.code, message: error.message, details: nil))
          }
        } catch {
          await session.stop()
          await MainActor.run {
            self.sessionBox = nil
            result(FlutterError(code: "unknown", message: "\(error)", details: nil))
          }
        }
      }
    case "setSegmentPause":
      guard let args = call.arguments as? [String: Any], let pauseMs = args["segmentPauseMs"] as? Int
      else {
        result(FlutterError(code: "arguments", message: "segmentPauseMs required", details: nil))
        return
      }
      Task {
        await self.session?.setSegmentPause(.milliseconds(pauseMs))
        await MainActor.run { result(nil) }
      }
    case "stop":
      Task {
        await self.session?.stop()
        await MainActor.run {
          self.sessionBox = nil
          result(nil)
        }
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  @available(iOS 26.0, *)
  private var session: DictationSession? { sessionBox as? DictationSession }

  /// Events reach Flutter on the main thread, whichever thread produced them.
  private func makeEmitter() -> DictationEmit {
    return { [weak self] payload in
      DispatchQueue.main.async { self?.eventSink?(payload) }
    }
  }
}

/// Delivers an event-channel payload; declared outside the iOS 26 types so
/// the plugin class compiles on every deployment target.
typealias DictationEmit = @Sendable ([String: Any]) -> Void

enum DictationError: Error {
  case unsupportedLocale
  case assets(String)
  case audio(String)

  var code: String {
    switch self {
    case .unsupportedLocale: return "unsupportedLocale"
    case .assets: return "assets"
    case .audio: return "audio"
    }
  }

  var message: String {
    switch self {
    case .unsupportedLocale: return "No on-device model for this locale"
    case .assets(let detail): return detail
    case .audio(let detail): return detail
    }
  }
}

/// One microphone-to-transcript pipeline. An actor: audio callbacks, result
/// delivery and channel calls arrive on different threads.
@available(iOS 26.0, *)
actor DictationSession {
  init(segmentPause: Duration, emit: @escaping DictationEmit) {
    self.segmentPause = segmentPause
    self.emit = emit
  }

  private let emit: DictationEmit
  private let engine = AVAudioEngine()
  private var segmentPause: Duration
  private var analyzer: SpeechAnalyzer?
  private var transcriber: SpeechTranscriber?
  private var input: AsyncStream<AnalyzerInput>.Continuation?
  private var analyzerFormat: AVAudioFormat?
  private var converter: AVAudioConverter?
  private var resultsTask: Task<Void, Never>?
  private var silenceTask: Task<Void, Never>?
  private var lastLevelAt = ContinuousClock.now

  func start(locale: Locale) async throws {
    let transcriber = SpeechTranscriber(
      locale: locale,
      transcriptionOptions: [],
      reportingOptions: [.volatileResults],
      attributeOptions: [])
    try await Self.ensureAssets(for: transcriber, locale: locale)

    let analyzer = SpeechAnalyzer(modules: [transcriber])
    guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith: [transcriber])
    else { throw DictationError.audio("No audio format compatible with the analyzer") }

    let (stream, continuation) = AsyncStream<AnalyzerInput>.makeStream()
    self.transcriber = transcriber
    self.analyzer = analyzer
    self.input = continuation
    self.analyzerFormat = format

    let emit = self.emit
    resultsTask = Task { [weak self] in
      do {
        for try await result in transcriber.results {
          await self?.handle(result)
        }
      } catch {
        emit(["type": "error", "code": "unknown", "message": "\(error)"])
      }
    }

    try await analyzer.start(inputSequence: stream)
    try configureAudioSession()
    try startEngine(format: format)
  }

  func setSegmentPause(_ pause: Duration) {
    segmentPause = pause
  }

  func stop() async {
    silenceTask?.cancel()
    silenceTask = nil
    if engine.isRunning {
      engine.inputNode.removeTap(onBus: 0)
      engine.stop()
    }
    input?.finish()
    input = nil
    if let analyzer {
      // Delivers the final result for whatever was said last, then ends the
      // results sequence, which lets resultsTask finish on its own.
      try? await analyzer.finalizeAndFinishThroughEndOfInput()
    }
    analyzer = nil
    transcriber = nil
    converter = nil
    resultsTask = nil
    try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
  }

  // MARK: - Setup

  private static func ensureAssets(for transcriber: SpeechTranscriber, locale: Locale) async throws {
    let wanted = locale.identifier(.bcp47).lowercased()
    let supported = await SpeechTranscriber.supportedLocales
    guard supported.contains(where: { $0.identifier(.bcp47).lowercased() == wanted }) else {
      throw DictationError.unsupportedLocale
    }
    do {
      if let request = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
        try await request.downloadAndInstall()
      }
    } catch {
      throw DictationError.assets("Speech model download failed: \(error)")
    }
  }

  private func configureAudioSession() throws {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(
        .playAndRecord, mode: .spokenAudio,
        options: [.duckOthers, .defaultToSpeaker, .allowBluetoothHFP])
      try session.setActive(true, options: .notifyOthersOnDeactivation)
    } catch {
      throw DictationError.audio("Audio session unavailable: \(error)")
    }
  }

  private func startEngine(format: AVAudioFormat) throws {
    let inputNode = engine.inputNode
    let inputFormat = inputNode.outputFormat(forBus: 0)
    guard let converter = AVAudioConverter(from: inputFormat, to: format) else {
      throw DictationError.audio("Cannot convert microphone audio for the analyzer")
    }
    self.converter = converter
    inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
      guard let self else { return }
      Task { await self.feed(buffer) }
    }
    engine.prepare()
    do {
      try engine.start()
    } catch {
      throw DictationError.audio("Microphone unavailable: \(error)")
    }
  }

  // MARK: - Audio

  private func feed(_ buffer: AVAudioPCMBuffer) {
    emitLevel(from: buffer)
    guard let converter, let format = analyzerFormat, let input else { return }
    let ratio = format.sampleRate / buffer.format.sampleRate
    let capacity = AVAudioFrameCount((Double(buffer.frameLength) * ratio).rounded(.up)) + 1
    guard let converted = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: capacity) else { return }
    var consumed = false
    var error: NSError?
    let status = converter.convert(to: converted, error: &error) { _, outStatus in
      if consumed {
        outStatus.pointee = .noDataNow
        return nil
      }
      consumed = true
      outStatus.pointee = .haveData
      return buffer
    }
    guard status != .error, converted.frameLength > 0 else { return }
    input.yield(AnalyzerInput(buffer: converted))
  }

  /// Roughly ten readings a second, in decibels relative to full scale.
  private func emitLevel(from buffer: AVAudioPCMBuffer) {
    let now = ContinuousClock.now
    guard now - lastLevelAt > .milliseconds(100) else { return }
    lastLevelAt = now
    guard let channel = buffer.floatChannelData?[0], buffer.frameLength > 0 else { return }
    var sum: Float = 0
    for i in 0..<Int(buffer.frameLength) {
      sum += channel[i] * channel[i]
    }
    let rms = (sum / Float(buffer.frameLength)).squareRoot()
    let decibels = 20 * log10(max(rms, 1e-6))
    emit(["type": "level", "decibels": Double(decibels)])
  }

  // MARK: - Results

  private func handle(_ result: SpeechTranscriber.Result) {
    let text = String(result.text.characters)
    emit(["type": "transcript", "text": text, "isFinal": result.isFinal])
    if result.isFinal {
      silenceTask?.cancel()
      silenceTask = nil
    } else {
      restartSilenceTimer()
    }
  }

  /// Volatile text that stops changing for `segmentPause` is finalized, which
  /// is how a spoken list splits into items.
  private func restartSilenceTimer() {
    silenceTask?.cancel()
    let pause = segmentPause
    silenceTask = Task { [weak self] in
      try? await Task.sleep(for: pause)
      guard !Task.isCancelled else { return }
      await self?.finalizePending()
    }
  }

  private func finalizePending() async {
    guard let analyzer else { return }
    do {
      try await analyzer.finalize(through: nil)
    } catch {
      emit(["type": "error", "code": "unknown", "message": "\(error)"])
    }
  }
}
