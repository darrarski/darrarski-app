import Dependencies
import Foundation
import TelemetryClient
import XCTestDynamicOverlay
import OSLog

struct AppTelemetryClient: Sendable {
  var initialize: @Sendable () -> Void
  var send: @Sendable (AppTelemetrySignal) -> Void

  func send(_ signalType: String) {
    send(AppTelemetrySignal(type: signalType))
  }
}

extension AppTelemetryClient: TestDependencyKey {
  static let testValue = AppTelemetryClient(
    initialize: unimplemented("\(Self.self).initialize"),
    send: unimplemented("\(Self.self).send")
  )

  static let previewValue = AppTelemetryClient(
    initialize: { print("AppTelemetryClient.initialize()") },
    send: { print(#"AppTelemetryClient.send("\#($0)")"#) }
  )
}

extension DependencyValues {
  var appTelemetry: AppTelemetryClient {
    get { self[AppTelemetryClient.self] }
    set { self[AppTelemetryClient.self] = newValue }
  }
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

  private static func appID() -> String? {
    let data = Data(PackageResources.TelemetryDeckAppID)
    let string = String(data: data, encoding: .utf8)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let string, !string.isEmpty else {
      let log = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "AppTelemetryClient"
      )
      log.fault("Missing TelemetryDeck AppID (app/Sources/AppFeature/Secrets/TelemetryDeckAppID)")
      return nil
    }
    return string
  }
}
