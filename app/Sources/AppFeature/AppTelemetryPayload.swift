import ContactFeature
import Foundation
import Mastodon
import ProjectsFeature

protocol AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] { get }
}

extension Contact.Link: AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] { id.appTelemetryPayload }
}

extension Contact.Link.ID: AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] { ["contact.link.id": rawValue] }
}

extension Project: AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String : String] { id.appTelemetryPayload }
}

extension Project.ID: AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] {
    ["project.id": "\(DateFormatter.yearMonthDay.string(from: date)) \(name)"]
  }
}

extension Mastodon.Status: AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] { id.appTelemetryPayload }
}

extension Mastodon.Status.ID: AppTelemetryPayloadProviding {
  var appTelemetryPayload: [String: String] { ["mastodon.status.id": rawValue] }
}

private extension DateFormatter {
  static let yearMonthDay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
}
