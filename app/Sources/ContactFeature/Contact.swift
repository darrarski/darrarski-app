import Foundation

public struct Contact: Equatable, Sendable, Codable {
  public init(
    avatarURL: URL,
    name: String,
    description: String,
    links: [Link]
  ) {
    self.avatarURL = avatarURL
    self.name = name
    self.description = description
    self.links = links
  }
  
  public var avatarURL: URL
  public var name: String
  public var description: String
  public var links: [Link]
}

extension Contact {
  public struct Link: Equatable, Sendable, Codable, Identifiable {
    public init(
      id: String,
      title: String,
      url: URL,
      iconURL: URL?,
      target: Target
    ) {
      self.id = id
      self.title = title
      self.url = url
      self.iconURL = iconURL
      self.target = target
    }
    
    public var id: String
    public var title: String
    public var url: URL
    public var iconURL: URL?
    public var target: Target
  }
}

extension Contact.Link {
  public enum Target: String, Equatable, Sendable, Codable {
    case system

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let stringValue = try container.decode(String.self)
      guard let target = Target(rawValue: stringValue) else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "")
      }
      self = target
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(rawValue)
    }
  }
}

extension Contact {
  public static let preview = Contact(
    avatarURL: URL(string: "https://2.gravatar.com/avatar/6050a5cb46e4ae93355bbe6c95931ea5?s=512")!,
    name: "Dariusz Rybicki",
    description: """
      Software Engineer,
      iOS & Mac App Developer,
      Scrum Master, Mentor
      """,
    links: [
      Link(
        id: "mail",
        title: "Mail",
        url: URL(string: "mailto:dariusz@darrarski.pl")!,
        iconURL: URL(string: "sf-symbols:envelope.fill")!,
        target: .system
      ),
      Link(
        id: "mastodon.social",
        title: "Mastodon",
        url: URL(string: "https://mastodon.social/@darrarski")!,
        iconURL: URL(string: "https://app.darrarski.pl/assets/icons/mastodon.png")!,
        target: .system
      ),
      Link(
        id: "twitter",
        title: "Twitter",
        url: URL(string: "https://twitter.com/darrarski")!,
        iconURL: URL(string: "https://app.darrarski.pl/assets/icons/twitter.png")!,
        target: .system
      ),
      Link(
        id: "linked-in",
        title: "Linked In",
        url: URL(string: "https://www.linkedin.com/in/darrarski")!,
        iconURL: URL(string: "https://app.darrarski.pl/assets/icons/linked-in.png")!,
        target: .system
      ),
      Link(
        id: "github",
        title: "GitHub",
        url: URL(string: "https://github.com/darrarski")!,
        iconURL: URL(string: "https://app.darrarski.pl/assets/icons/github.png")!,
        target: .system
      ),
      Link(
        id: "cal.com",
        title: "Book a meeting",
        url: URL(string: "https://cal.com/darrarski")!,
        iconURL: URL(string: "sf-symbols:calendar.badge.plus")!,
        target: .system
      ),
    ]
  )
}
