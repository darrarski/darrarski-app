import Foundation

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
        output.characters.insert(contentsOf: "\n", at: intentRange.lowerBound)
      }
    }
    self = output
  }
}
