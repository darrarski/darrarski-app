import AppSecrets
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
    send(AppTelemetrySignal(name: signalType))
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
    initialize: { log.value.debug("initialize") },
    send: { log.value.debug("send \($0.name)\($0.parameters.isEmpty ? "" : " \($0.parameters)")") }
  )
}

extension AppTelemetryClient: DependencyKey {
  static let liveValue = AppTelemetryClient(
    initialize: {
      guard !TelemetryManager.isInitialized,
            let appID = Self.appID() else { return }
      TelemetryDeck.initialize(config: .init(appID: appID))
    },
    send: { signal in
      guard TelemetryManager.isInitialized else { return }
      TelemetryDeck.signal(
        signal.name,
        parameters: signal.parameters,
        floatValue: signal.floatValue,
        customUserID: signal.customUserID
      )
    }
  )

  private static let log = UncheckedSendable(
    Logger(
      subsystem: Bundle.main.bundleIdentifier!,
      category: "AppTelemetryClient"
    )
  )

  private static func appID() -> String? {
    @Dependency(AppSecrets.self) var appSecrets
    let data = appSecrets.telemetryDeckAppID()
    let string = String(data: data, encoding: .utf8)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let string, !string.isEmpty else {
      log.value.fault("Missing TelemetryDeck AppID.")
      return nil
    }
    guard UUID(uuidString: string) != nil else {
      log.value.fault("Invalid TelemetryDeck AppID (expected UUID).")
      return nil
    }
    return string
  }
}
