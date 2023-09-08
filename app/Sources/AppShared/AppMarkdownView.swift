import SwiftUI

public struct AppMarkdownView: View {
  public init(markdown: String) {
    self.markdown = markdown
  }

  var markdown: String
  @State var attributedString: AttributedString?

  public var body: some View {
    Text(attributedString ?? AttributedString())
      .onChange(of: markdown, initial: true) { _, newValue in
        attributedString = try? AttributedString(appMarkdown: newValue)
      }
  }
}
