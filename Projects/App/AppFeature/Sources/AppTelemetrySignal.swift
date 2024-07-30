struct AppTelemetrySignal: Equatable, Sendable {
  var name: String
  var parameters: [String: String] = [:]
  var floatValue: Double?
  var customUserID: String?
}
