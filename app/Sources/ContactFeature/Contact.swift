import Foundation

public struct Contact: Equatable, Sendable {
  public init(
    avatarURL: URL,
    name: String,
    description: String,
    content: AttributedString,
    links: [Link]
  ) {
    self.avatarURL = avatarURL
    self.name = name
    self.description = description
    self.content = content
    self.links = links
  }
  
  public var avatarURL: URL
  public var name: String
  public var description: String
  public var content: AttributedString
  public var links: [Link]
}

extension Contact: Decodable {
  enum CodingKeys: CodingKey {
    case avatarURL
    case name
    case description
    case content
    case links
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.avatarURL = try container.decode(URL.self, forKey: .avatarURL)
    self.name = try container.decode(String.self, forKey: .name)
    self.description = try container.decode(String.self, forKey: .description)
    let content = try container.decode(String.self, forKey: .content)
    self.content = try AttributedString(appMarkdown: content)
    self.links = try container.decode([Link].self, forKey: .links)
  }
}

extension Contact {
  public struct Link: Equatable, Sendable, Decodable {
    public init(
      id: String,
      title: String,
      url: URL,
      iconURL: URL?,
      target: Target
    ) {
      self.id = ID(rawValue: id)
      self.title = title
      self.url = url
      self.iconURL = iconURL
      self.target = target
    }
    
    public var id: ID
    public var title: String
    public var url: URL
    public var iconURL: URL?
    public var target: Target
  }
}

extension Contact.Link: Identifiable {
  public struct ID: Hashable, Sendable, Decodable {
    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.rawValue = try container.decode(String.self)
    }

    public var rawValue: String

    public func encode(to encoder: Encoder) throws {
      var container = encoder.singleValueContainer()
      try container.encode(self.rawValue)
    }
  }
}

extension Contact.Link {
  public enum Target: String, Equatable, Sendable, Decodable {
    case system

    public init(from decoder: Decoder) throws {
      let container = try decoder.singleValueContainer()
      let stringValue = try container.decode(String.self)
      guard let target = Target(rawValue: stringValue) else {
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "")
      }
      self = target
    }
  }
}

extension Contact {
  public static let preview: Contact = {
    let url = Bundle.module.url(forResource: "contact_preview", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try! decoder.decode(Contact.self, from: data)
  }()
}
