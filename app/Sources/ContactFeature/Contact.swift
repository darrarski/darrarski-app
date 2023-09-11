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
  public struct Link: Equatable, Sendable, Codable {
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
  public struct ID: Hashable, Sendable, Codable {
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
  public static let preview: Contact = {
    let url = Bundle.module.url(forResource: "contact_preview", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try! decoder.decode(Contact.self, from: data)
  }()
}
