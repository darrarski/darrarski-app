import ContactFeature
import Foundation
import Mastodon
import ProjectsFeature

protocol AppTelemetryParametersProviding {
  var appTelemetryParameters: [String: String] { get }
}

extension Contact.Link: AppTelemetryParametersProviding {
  var appTelemetryParameters: [String: String] { id.appTelemetryParameters }
}

extension Contact.Link.ID: AppTelemetryParametersProviding {
  var appTelemetryParameters: [String: String] { ["contact.link.id": rawValue] }
}

extension Project: AppTelemetryParametersProviding {
  var appTelemetryParameters: [String : String] { id.appTelemetryParameters }
}

extension Project.ID: AppTelemetryParametersProviding {
  var appTelemetryParameters: [String: String] {
    ["project.id": "\(DateFormatter.yearMonthDay.string(from: date)) \(name)"]
  }
}

extension Mastodon.Status: AppTelemetryParametersProviding {
  var appTelemetryParameters: [String: String] { id.appTelemetryParameters }
}

extension Mastodon.Status.ID: AppTelemetryParametersProviding {
  var appTelemetryParameters: [String: String] { ["mastodon.status.id": rawValue] }
}

extension Mastodon.MediaAttachment: AppTelemetryParametersProviding {
  var appTelemetryParameters: [String: String] { id.appTelemetryParameters }
}

extension Mastodon.MediaAttachment.ID: AppTelemetryParametersProviding {
  var appTelemetryParameters: [String: String] { ["mastodon.media-attachment.id": rawValue] }
}

private extension DateFormatter {
  static let yearMonthDay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
  }()
}
