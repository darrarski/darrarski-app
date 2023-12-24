import Dependencies
import DependenciesMacros
import Foundation
import SwiftHTMLtoMarkdown
import XCTestDynamicOverlay

@DependencyClient
struct StatusTextRenderer: Sendable {
  var render: @Sendable (String) throws -> AttributedString

  func callAsFunction(_ html: String) throws -> AttributedString {
    try render(html)
  }
}

extension DependencyValues {
  var statusTextRenderer: StatusTextRenderer {
    get { self[StatusTextRenderer.self] }
    set { self[StatusTextRenderer.self] = newValue }
  }
}

extension StatusTextRenderer: DependencyKey {
  static let testValue = StatusTextRenderer()
  static let liveValue = StatusTextRenderer { html in
    var document = MastodonHTML(rawHTML: html)
    try document.parse()
    let markdown = try document.asMarkdown()
    return try AttributedString(appMarkdown: markdown)
  }
}
