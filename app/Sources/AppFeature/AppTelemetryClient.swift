import Dependencies
import DependenciesMacros
import Foundation
import TelemetryClient
import XCTestDynamicOverlay
import OSLog

@DependencyClient
struct AppTelemetryClient: Sendable {
  var initialize: @Sendable () -> Void
  var send: @Sendable (AppTelemetrySignal) -> Void

  func send(_ signalType: String) {
    send(AppTelemetrySignal(type: signalType))
  }
}

extension DependencyValues {
  var appTelemetry: AppTelemetryClient {
    get { self[AppTelemetryClient.self] }
    set { self[AppTelemetryClient.self] = newValue }
  }
}

extension AppTelemetryClient: TestDependencyKey {
  static let testValue = AppTelemetryClient()
  static let previewValue = AppTelemetryClient(
    initialize: { log.debug("initialize") },
    send: { log.debug("send \($0.type)\($0.payload.isEmpty ? "" : " \($0.payload)")") }
  )
}

extension AppTelemetryClient: DependencyKey {
  static let liveValue = AppTelemetryClient(
    initialize: {
      guard !TelemetryManager.isInitialized, let appID = Self.appID() else { return }
      TelemetryManager.initialize(with: .init(appID: appID))
    },
    send: { signal in
      guard TelemetryManager.isInitialized else { return }
      TelemetryManager.send(
        signal.type,
        for: signal.clientUser,
        floatValue: signal.floatValue,
        with: signal.payload
      )
    }
  )

  private static let log = Logger(
    subsystem: Bundle.main.bundleIdentifier!,
    category: "AppTelemetryClient"
  )

  private static func appID() -> String? {
    let data = Data(PackageResources.TelemetryDeckAppID)
    let string = String(data: data, encoding: .utf8)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let string, !string.isEmpty else {
      log.fault("Missing TelemetryDeck AppID (app/Sources/AppFeature/Secrets/TelemetryDeckAppID)")
      return nil
    }
    return string
  }
}
