import Dependencies
import Foundation
import SwiftHTMLtoMarkdown
import XCTestDynamicOverlay

struct StatusTextRenderer: Sendable {
  typealias Render = @Sendable (String) throws -> AttributedString

  var render: Render

  func callAsFunction(_ html: String) throws -> AttributedString {
    try render(html)
  }
}

extension StatusTextRenderer: DependencyKey {
  static let testValue = StatusTextRenderer(
    render: unimplemented("\(Self.self)")
  )

  static let liveValue = StatusTextRenderer { html in
    var document = MastodonHTML(rawHTML: html)
    try document.parse()
    let markdown = try document.asMarkdown()
    return try AttributedString(appMarkdown: markdown)
  }
}

extension DependencyValues {
  var statusTextRenderer: StatusTextRenderer {
    get { self[StatusTextRenderer.self] }
    set { self[StatusTextRenderer.self] = newValue }
  }
}
