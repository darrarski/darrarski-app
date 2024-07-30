import Foundation

public struct ProjectsInfo: Equatable, Sendable {
  public init(content: AttributedString) {
    self.content = content
  }
  
  public var content: AttributedString
}

extension ProjectsInfo {
  public static let preview: ProjectsInfo = {
    let url = Bundle.module.url(forResource: "projects_preview", withExtension: "md")!
    let string = try! String(contentsOf: url)
    let content = try! AttributedString(appMarkdown: string)
    return ProjectsInfo(content: content)
  }()
}
