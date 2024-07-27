/// Represents a custom emoji.
///
/// [API documentation](https://docs.joinmastodon.org/entities/CustomEmoji/)
public struct CustomEmoji: Sendable, Equatable, Decodable {
  public init(
    shortcode: String,
    url: String,
    staticUrl: String,
    visibleInPicker: Bool,
    category: String?
  ) {
    self.shortcode = shortcode
    self.url = url
    self.staticUrl = staticUrl
    self.visibleInPicker = visibleInPicker
    self.category = category
  }

  public var shortcode: String
  public var url: String
  public var staticUrl: String
  public var visibleInPicker: Bool
  public var category: String?
}
