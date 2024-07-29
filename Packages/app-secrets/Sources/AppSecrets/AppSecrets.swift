import Foundation

public struct AppSecrets: Sendable {
  public init(
    telemetryDeckAppID: @escaping @Sendable () -> Data = { Data() }
  ) {
    self.telemetryDeckAppID = telemetryDeckAppID
  }
  
  public var telemetryDeckAppID: @Sendable () -> Data
}

extension AppSecrets {
  public static let live = AppSecrets(
    telemetryDeckAppID: {
      Data(PackageResources.TelemetryDeckAppID)
    }
  )
}
