import Foundation
import SwiftUI

/// Custom URL representation for referncing SF Symbols
///
/// Example URL:
/// ```
/// sf-symbols:calendar.badge.plus?rendering=multicolor
/// ```
/// - Path is the SF Symbol name (`calendar.badge.plus`).
/// - Optional `rendering` parameter is a string representation of `SymbolRenderingMode` enum value (`multicolor`).
public struct SFSymbolURL {
  public init?(_ url: URL) {
    guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
          components.scheme == "sf-symbols",
          components.path.isEmpty == false
    else {
      return nil
    }
    name = components.path
    switch components.queryItems?.first(where: { $0.name == "rendering" })?.value {
    case "hierarchical":
      rendering = .hierarchical
    case "monochrome":
      rendering = .monochrome
    case "multicolor":
      rendering = .multicolor
    case "palette":
      rendering = .palette
    default:
      rendering = nil
    }
  }

  public var name: String
  public var rendering: SymbolRenderingMode?
}
