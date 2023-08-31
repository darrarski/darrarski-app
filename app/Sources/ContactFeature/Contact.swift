import Foundation

public struct Contact: Equatable, Sendable, Codable {
  public init(
    avatarURL: URL,
    name: String,
    description: String
  ) {
    self.avatarURL = avatarURL
    self.name = name
    self.description = description
  }
  
  public var avatarURL: URL
  public var name: String
  public var description: String
}

extension Contact {
  public static let preview = Contact(
    avatarURL: URL(string: "https://2.gravatar.com/avatar/6050a5cb46e4ae93355bbe6c95931ea5?s=512")!,
    name: "Dariusz Rybicki",
    description: """
      Software Engineer,
      iOS & Mac App Developer,
      Scrum Master, Mentor
      """
  )
}
