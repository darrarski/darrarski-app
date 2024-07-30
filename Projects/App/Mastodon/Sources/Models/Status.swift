import Foundation

/// Represents a status posted by an account.
///
/// [API documentation](https://docs.joinmastodon.org/entities/Status/)
public struct Status: Sendable, Equatable, Decodable {
  public init(
    id: String,
    uri: String,
    createdAt: Date,
    account: Account,
    content: String,
    visibility: Visibility,
    sensitive: Bool,
    spoilerText: String,
    mediaAttachments: [MediaAttachment],
    application: Application?,
    mentions: [Status.Mention],
    tags: [Status.Tag],
    emojis: [CustomEmoji],
    reblogsCount: Int,
    favouritesCount: Int,
    repliesCount: Int,
    url: String?,
    inReplyToId: String?,
    inReplyToAccountId: String?,
    reblog: Indirect<Status>?,
    poll: Poll?,
    card: PreviewCard?,
    language: String?,
    text: String?,
    editedAt: Date?,
    favourited: Bool?,
    reblogged: Bool?,
    muted: Bool?,
    bookmarked: Bool?,
    pinned: Bool?
  ) {
    self.id = ID(rawValue: id)
    self.uri = uri
    self.createdAt = createdAt
    self.account = account
    self.content = content
    self.visibility = visibility
    self.sensitive = sensitive
    self.spoilerText = spoilerText
    self.mediaAttachments = mediaAttachments
    self.application = application
    self.mentions = mentions
    self.tags = tags
    self.emojis = emojis
    self.reblogsCount = reblogsCount
    self.favouritesCount = favouritesCount
    self.repliesCount = repliesCount
    self.url = url
    self.inReplyToId = inReplyToId
    self.inReplyToAccountId = inReplyToAccountId
    self.reblog = reblog
    self.poll = poll
    self.card = card
    self.language = language
    self.text = text
    self.editedAt = editedAt
    self.favourited = favourited
    self.reblogged = reblogged
    self.muted = muted
    self.bookmarked = bookmarked
    self.pinned = pinned
  }

  public var id: ID
  public var uri: String
  public var createdAt: Date
  public var account: Account
  public var content: String
  public var visibility: Visibility
  public var sensitive: Bool
  public var spoilerText: String
  public var mediaAttachments: [MediaAttachment]
  public var application: Application?
  public var mentions: [Mention]
  public var tags: [Tag]
  public var emojis: [CustomEmoji]
  public var reblogsCount: Int
  public var favouritesCount: Int
  public var repliesCount: Int
  public var url: String?
  public var inReplyToId: String?
  public var inReplyToAccountId: String?
  public var reblog: Indirect<Status>?
  public var poll: Poll?
  public var card: PreviewCard?
  public var language: String?
  public var text: String?
  public var editedAt: Date?
  public var favourited: Bool?
  public var reblogged: Bool?
  public var muted: Bool?
  public var bookmarked: Bool?
  public var pinned: Bool?
}

extension Status: Identifiable {
  public struct ID: Hashable, Sendable, Decodable {
    public init(rawValue: String) {
      self.rawValue = rawValue
    }

    public init(from decoder: any Decoder) throws {
      let container = try decoder.singleValueContainer()
      self.rawValue = try container.decode(String.self)
    }

    public var rawValue: String
  }
}

extension Status {
  /// Status.Mention
  ///
  /// [API documentation](https://docs.joinmastodon.org/entities/Status/#Mention)
  public struct Mention: Sendable, Equatable, Identifiable, Decodable {
    public init(
      id: String,
      username: String,
      url: String,
      acct: String
    ) {
      self.id = id
      self.username = username
      self.url = url
      self.acct = acct
    }

    public var id: String
    public var username: String
    public var url: String
    public var acct: String
  }
}

extension Status {
  /// Status.Tag
  ///
  /// [API documentation](https://docs.joinmastodon.org/entities/Status/#Tag)
  public struct Tag: Sendable, Equatable, Decodable {
    public init(
      name: String,
      url: String
    ) {
      self.name = name
      self.url = url
    }

    public var name: String
    public var url: String
  }
}

extension Status {
  /// Status.Visibility
  ///
  /// [API documentation](https://docs.joinmastodon.org/entities/Status/#visibility)
  public enum Visibility: String, Sendable, Equatable, Decodable {
    case `public`
    case unlisted
    case `private`
    case direct
  }
}

extension Array<Status> {
  /// Source: [@darrarski@mastodon.social statuses](https://mastodon.social/api/v1/accounts/108131495937150285/statuses?limit=5&exclude_replies=true)
  public static let preview: [Status] = {
    let decoder = JSONDecoder.mastodon
    return try! decoder.decode([Status].self, from: [Status].previewJSON)
  }()

  public static let previewJSON: Data = {
    let url = Bundle.module.url(forResource: "statuses_preview", withExtension: "json")!
    return try! Data(contentsOf: url)
  }()
}
