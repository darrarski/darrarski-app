struct AppTelemetrySignal: Equatable, Sendable {
  var type: String
  var clientUser: String?
  var floatValue: Double?
  var payload: [String: String] = [:]
}
