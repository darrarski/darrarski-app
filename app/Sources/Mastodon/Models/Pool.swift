import Foundation

/// Represents a poll attached to a status.
///
/// [API documentation](https://docs.joinmastodon.org/entities/Poll/)
public struct Poll: Sendable, Equatable, Identifiable, Decodable {
  public init(
    id: String,
    expiresAt: Date?,
    expired: Bool,
    multiple: Bool,
    votesCount: Int,
    votersCount: Int?,
    options: [Poll.Option],
    emojis: [CustomEmoji],
    voted: Bool?,
    ownVotes: [Int]?
  ) {
    self.id = id
    self.expiresAt = expiresAt
    self.expired = expired
    self.multiple = multiple
    self.votesCount = votesCount
    self.votersCount = votersCount
    self.options = options
    self.emojis = emojis
    self.voted = voted
    self.ownVotes = ownVotes
  }

  public var id: String
  public var expiresAt: Date?
  public var expired: Bool
  public var multiple: Bool
  public var votesCount: Int
  public var votersCount: Int?
  public var options: [Option]
  public var emojis: [CustomEmoji]
  public var voted: Bool?
  public var ownVotes: [Int]?
}

extension Poll {
  /// Poll.Option
  ///
  /// [API documentation](https://docs.joinmastodon.org/entities/Poll/#Option)
  public struct Option: Sendable, Equatable, Decodable {
    public init(
      title: String,
      votesCount: Int?
    ) {
      self.title = title
      self.votesCount = votesCount
    }

    public var title: String
    public var votesCount: Int?
  }
}
