import Foundation
import SwiftUI

extension AttributedString {
  public init(appMarkdown markdownString: String) throws {
    var output = try AttributedString(
      markdown: markdownString,
      options: .init(
        allowsExtendedAttributes: true,
        interpretedSyntax: .full,
        failurePolicy: .returnPartiallyParsedIfPossible
      ),
      baseURL: nil
    )
    let runs = output.runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self].reversed()
    for (intentBlock, intentRange) in runs {
      guard let intentBlock = intentBlock else { continue }
      for intent in intentBlock.components {
        switch intent.kind {
        case .header(level: let level):
          switch level {
          case 1:
            output[intentRange].font = .system(.title).bold()
          case 2:
            output[intentRange].font = .system(.title2).bold()
          case 3:
            output[intentRange].font = .system(.title3).bold()
          default:
            break
          }
        default:
          break
        }
      }
      if intentRange.lowerBound != output.startIndex {
        output.characters.insert(contentsOf: "\n\n", at: intentRange.lowerBound)
      }
    }
    self = output
  }
}

#Preview {
  ScrollView {
    let markdown = """
# Header 1
## Header 2
### Header 3

Sunt sit **labore anim pariatur** eiusmod est *reprehenderit* in elit.

Consectetur __dolor ad mollit__ velit aute aliqua elit _deserunt_ non velit consectetur quis pariatur.
Tempor nulla [incididunt cupidatat](https://app.darrarski.pl) excepteur duis aute magna do.
Commodo officia anim `elit consequat` aliqua mollit nisi eu consequat veniam sunt Lorem eu.

Qui ut nisi et magna sint.
"""
    let attributedString = try! AttributedString(appMarkdown: markdown)

    Text(attributedString)
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()
  }
  .tint(.appTint)
}
