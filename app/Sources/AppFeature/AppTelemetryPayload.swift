import ContactFeature

protocol AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] { get }
}

extension Contact.Link: AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] { id.appTelemetryPayload }
}

extension Contact.Link.ID: AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] { ["contact.link.id": rawValue] }
}
