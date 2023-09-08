import SwiftUI

public struct AppMarkdownView: View {
  public init(markdown: String) {
    self.markdown = markdown
  }

  var markdown: String
  @State var attributedString: AttributedString?

  public var body: some View {
    Text(attributedString ?? AttributedString())
      .task(id: markdown, priority: .userInitiated) {
        let task = Task.detached { [markdown] in
          try? AttributedString(appMarkdown: markdown)
        }
        attributedString = await task.value
      }
  }
}
