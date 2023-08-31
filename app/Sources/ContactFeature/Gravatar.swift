import CryptoKit
import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct GravatarJSON: Equatable, Sendable, Codable {
  public init(entry: [Entry]) {
    self.entry = entry
  }

  public var entry: [Entry]
}

extension GravatarJSON {
  public struct Entry: Equatable, Sendable, Codable {
    public init(
      hash: String,
      requestHash: String,
      profileUrl: Foundation.URL,
      preferredUsername: String,
      thumbnailUrl: Foundation.URL,
      photos: [GravatarJSON.Entry.Photo],
      name: GravatarJSON.Entry.Name,
      displayName: String,
      aboutMe: String,
      currentLocation: String,
      emails: [GravatarJSON.Entry.Email],
      accounts: [GravatarJSON.Entry.Account],
      urls: [GravatarJSON.Entry.URL]
    ) {
      self.hash = hash
      self.requestHash = requestHash
      self.profileUrl = profileUrl
      self.preferredUsername = preferredUsername
      self.thumbnailUrl = thumbnailUrl
      self.photos = photos
      self.name = name
      self.displayName = displayName
      self.aboutMe = aboutMe
      self.currentLocation = currentLocation
      self.emails = emails
      self.accounts = accounts
      self.urls = urls
    }

    enum CodingKeys: CodingKey {
      case hash
      case requestHash
      case profileUrl
      case preferredUsername
      case thumbnailUrl
      case photos
      case name
      case displayName
      case aboutMe
      case currentLocation
      case emails
      case accounts
      case urls
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.hash = try container.decode(String.self, forKey: .hash)
      self.requestHash = try container.decode(String.self, forKey: .requestHash)
      self.profileUrl = try container.decode(Foundation.URL.self, forKey: .profileUrl)
      self.preferredUsername = try container.decode(String.self, forKey: .preferredUsername)
      self.thumbnailUrl = try container.decode(Foundation.URL.self, forKey: .thumbnailUrl)
      self.photos = try container.decode([GravatarJSON.Entry.Photo].self, forKey: .photos)
      self.name = try container.decode(GravatarJSON.Entry.Name.self, forKey: .name)
      self.displayName = try container.decode(String.self, forKey: .displayName)
      self.aboutMe = try container.decode(String.self, forKey: .aboutMe)
        .replacingOccurrences(of: "&amp;", with: "&")
      self.currentLocation = try container.decode(String.self, forKey: .currentLocation)
      self.emails = try container.decode([Email].self, forKey: .emails)
      self.accounts = try container.decode([Account].self, forKey: .accounts)
      self.urls = try container.decode([GravatarJSON.Entry.URL].self, forKey: .urls)
    }

    public var hash: String
    public var requestHash: String
    public var profileUrl: Foundation.URL
    public var preferredUsername: String
    public var thumbnailUrl: Foundation.URL
    public var photos: [Photo]
    public var name: Name
    public var displayName: String
    public var aboutMe: String
    public var currentLocation: String
    public var emails: [Email]
    public var accounts: [Account]
    public var urls: [GravatarJSON.Entry.URL]
  }
}

extension GravatarJSON.Entry {
  public struct Account: Equatable, Sendable, Codable {
    enum CodingKeys: CodingKey {
      case domain
      case display
      case url
      case iconUrl
      case username
      case verified
      case name
      case shortname
    }

    public init(
      domain: String,
      display: String,
      url: Foundation.URL,
      iconUrl: Foundation.URL,
      username: String,
      verified: Bool,
      name: String,
      shortname: String
    ) {
      self.domain = domain
      self.display = display
      self.url = url
      self.iconUrl = iconUrl
      self.username = username
      self.verified = verified
      self.name = name
      self.shortname = shortname
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      self.domain = try container.decode(String.self, forKey: .domain)
      self.display = try container.decode(String.self, forKey: .display)
      self.url = try container.decode(Foundation.URL.self, forKey: .url)
      self.iconUrl = try container.decode(Foundation.URL.self, forKey: .iconUrl)
      self.username = try container.decode(String.self, forKey: .username)
      let verifiedString = try container.decode(String.self, forKey: .verified)
      guard let verified = Bool(verifiedString) else {
        throw DecodingError.dataCorruptedError(
          forKey: .verified,
          in: container,
          debugDescription: #"Expected string representation of a boolean value, got "\#(verifiedString)""#
        )
      }
      self.verified = verified
      self.name = try container.decode(String.self, forKey: .name)
      self.shortname = try container.decode(String.self, forKey: .shortname)
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(domain, forKey: .domain)
      try container.encode(display, forKey: .display)
      try container.encode(url, forKey: .url)
      try container.encode(iconUrl, forKey: .iconUrl)
      try container.encode(username, forKey: .username)
      try container.encode(verified ? "true" : "false", forKey: .verified)
      try container.encode(name, forKey: .name)
      try container.encode(shortname, forKey: .shortname)
    }

    public var domain: String
    public var display: String
    public var url: Foundation.URL
    public var iconUrl: Foundation.URL
    public var username: String
    public var verified: Bool
    public var name: String
    public var shortname: String
  }
}


extension GravatarJSON.Entry {
  public struct URL: Equatable, Sendable, Codable {
    public init(value: Foundation.URL, title: String) {
      self.value = value
      self.title = title
    }

    public var value: Foundation.URL
    public var title: String
  }
}

extension GravatarJSON.Entry {
  public struct Photo: Equatable, Sendable, Codable {
    public init(value: Foundation.URL, type: String) {
      self.value = value
      self.type = type
    }

    public var value: Foundation.URL
    public var type: String
  }
}

extension GravatarJSON.Entry {
  public struct Name: Equatable, Sendable, Codable {
    public init(givenName: String, familyName: String, formatted: String) {
      self.givenName = givenName
      self.familyName = familyName
      self.formatted = formatted
    }

    public var givenName: String
    public var familyName: String
    public var formatted: String
  }
}

extension GravatarJSON.Entry {
  public struct Email: Equatable, Sendable, Codable {
    enum CodingKeys: CodingKey {
      case primary
      case value
    }

    public init(primary: Bool, value: String) {
      self.primary = primary
      self.value = value
    }

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let primaryString = try container.decode(String.self, forKey: .primary)
      guard let primary = Bool(primaryString) else {
        throw DecodingError.dataCorruptedError(
          forKey: .primary,
          in: container,
          debugDescription: #"Expected string representation of a boolean value, got "\#(primaryString)""#
        )
      }
      self.primary = primary
      self.value = try container.decode(String.self, forKey: GravatarJSON.Entry.Email.CodingKeys.value)
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(primary ? "true" : "false", forKey: .primary)
      try container.encode(value, forKey: .value)
    }

    public var primary: Bool
    public var value: String
  }
}

public struct GravatarClient: Sendable {
  public typealias Fetch = @Sendable (String) async throws -> GravatarJSON

  public init(fetch: @escaping GravatarClient.Fetch) {
    self.fetch = fetch
  }

  public var fetch: Fetch

  public func fetch(email: String) async throws -> GravatarJSON {
    try await fetch(email)
  }
}

extension DependencyValues {
  public var gravatar: GravatarClient {
    get { self[GravatarClient.self] }
    set { self[GravatarClient.self] = newValue }
  }
}

extension GravatarClient: TestDependencyKey {
  public static let testValue = GravatarClient(
    fetch: unimplemented("\(Self.self).fetch")
  )

  public static var previewValue = GravatarClient(
    fetch: { _ in GravatarJSON.preview }
  )
}

extension GravatarJSON {
  static let preview: GravatarJSON = {
    let url = Bundle.module.url(forResource: "gravatar_preview", withExtension: "json")!
    let jsonData = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try! decoder.decode(GravatarJSON.self, from: jsonData)
  }()
}

extension GravatarClient: DependencyKey {
  public struct InvalidURLError: Error {
    public init() {}
  }

  public struct ResponseError: Error {
    public init(statusCode: Int?, data: Data) {
      self.statusCode = statusCode
      self.data = data
    }

    public var statusCode: Int?
    public var data: Data
  }

  public static let liveValue = GravatarClient { email in
    @Dependency(\.urlSession) var urlSession

    let hash = Insecure.MD5
      .hash(data: email.data(using: .utf8)!)
      .map {String(format: "%02x", $0)}
      .joined()
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "www.gravatar.com"
    urlComponents.path = "/\(hash).json"
    guard let url = urlComponents.url else {
      throw InvalidURLError()
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = "GET"
    let (data, response) = try await urlSession.data(for: urlRequest)
    let statusCode = (response as? HTTPURLResponse)?.statusCode
    guard let statusCode, (200..<300).contains(statusCode) else {
      throw ResponseError(statusCode: statusCode, data: data)
    }
    let decoder = JSONDecoder()
    let json = try decoder.decode(GravatarJSON.self, from: data)

    return json
  }
}
