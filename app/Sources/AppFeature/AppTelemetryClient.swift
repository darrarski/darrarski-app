import Dependencies
import TelemetryClient
import XCTestDynamicOverlay

struct AppTelemetryClient: Sendable {
  var initialize: @Sendable () -> Void
  var send: @Sendable (String) -> Void
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
      TelemetryManager.initialize(with: .init(
        appID: "" // TODO: TelemetryDeck AppID
      ))
    },
    send: { signal in
      TelemetryManager.send(signal)
    }
  )
}
