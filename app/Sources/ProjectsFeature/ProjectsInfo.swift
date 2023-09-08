import Foundation

public struct ProjectsInfo: Equatable, Sendable {
  public init(markdown: String) {
    self.markdown = markdown
  }
  
  public var markdown: String
}

extension ProjectsInfo {
  public static let preview: ProjectsInfo = {
    let url = Bundle.module.url(forResource: "projects_preview", withExtension: "md")!
    let string = try! String(contentsOf: url)
    return ProjectsInfo(markdown: string)
  }()
}
