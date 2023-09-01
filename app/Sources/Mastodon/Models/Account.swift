import Foundation

/// Represents a user of Mastodon and their associated profile.
///
/// [API documentation](https://docs.joinmastodon.org/entities/Account/)
public struct Account: Sendable, Equatable, Identifiable, Decodable {
  public init(
    id: String,
    username: String,
    acct: String,
    url: String,
    displayName: String,
    note: String,
    avatar: String,
    avatarStatic: String,
    header: String,
    headerStatic: String,
    locked: Bool,
    fields: [Account.Field],
    emojis: [CustomEmoji],
    bot: Bool,
    group: Bool,
    discoverable: Bool?,
    noindex: Bool?,
    moved: Indirect<Account>?,
    suspended: Bool?,
    limited: Bool?,
    createdAt: Date,
    lastStatusAt: Date?,
    statusesCount: Int,
    followersCount: Int,
    followingCount: Int
  ) {
    self.id = id
    self.username = username
    self.acct = acct
    self.url = url
    self.displayName = displayName
    self.note = note
    self.avatar = avatar
    self.avatarStatic = avatarStatic
    self.header = header
    self.headerStatic = headerStatic
    self.locked = locked
    self.fields = fields
    self.emojis = emojis
    self.bot = bot
    self.group = group
    self.discoverable = discoverable
    self.noindex = noindex
    self.moved = moved
    self.suspended = suspended
    self.limited = limited
    self.createdAt = createdAt
    self.lastStatusAt = lastStatusAt
    self.statusesCount = statusesCount
    self.followersCount = followersCount
    self.followingCount = followingCount
  }

  public var id: String
  public var username: String
  public var acct: String
  public var url: String
  public var displayName: String
  public var note: String
  public var avatar: String
  public var avatarStatic: String
  public var header: String
  public var headerStatic: String
  public var locked: Bool
  public var fields: [Field]
  public var emojis: [CustomEmoji]
  public var bot: Bool
  public var group: Bool
  public var discoverable: Bool?
  public var noindex: Bool?
  public var moved: Indirect<Account>?
  public var suspended: Bool?
  public var limited: Bool?
  public var createdAt: Date
  public var lastStatusAt: Date?
  public var statusesCount: Int
  public var followersCount: Int
  public var followingCount: Int
}

extension Account {
  /// Account.Field
  ///
  /// [API documentation](https://docs.joinmastodon.org/entities/Account/#Field)
  public struct Field: Sendable, Equatable, Decodable {
    public init(
      name: String,
      value: String,
      verifiedAt: Date?
    ) {
      self.name = name
      self.value = value
      self.verifiedAt = verifiedAt
    }

    public var name: String
    public var value: String
    public var verifiedAt: Date?
  }
}
