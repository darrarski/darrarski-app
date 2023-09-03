import Mastodon
import SwiftHTMLtoMarkdown
import SwiftUI

public struct HTMLTextView: View {
  public init(html: String) {
    self.html = html
  }

  var html: String
  @State var attributedString = AttributedString()

  public var body: some View {
    Text(attributedString)
      .task {
        attributedString = Self.attributedString(html: html)
      }
      .onChange(of: html) { _, newValue in
        attributedString = Self.attributedString(html: html)
      }
  }

  static func attributedString(html: String) -> AttributedString {
    var document = MastodonHTML(rawHTML: html)
    do {
      try document.parse()
      let markdown = try document.asMarkdown()
      return try AttributedString(markdown: markdown)
    } catch {
      return AttributedString(html)
    }
  }
}

#Preview {
  List {
    ForEach([Status].preview) { status in
      let content = status.content
      if !content.isEmpty {
        HTMLTextView(html: content)
      }
      if let content = status.reblog?.content, !content.isEmpty {
        HTMLTextView(html: content)
      }
    }
  }
  .tint(.appTint)
}
