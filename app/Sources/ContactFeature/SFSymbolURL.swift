import Foundation
import SwiftUI

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
