/// Represents a rich preview card that is generated using OpenGraph tags from a URL.
///
/// [API documentation](https://docs.joinmastodon.org/entities/PreviewCard/)
public struct PreviewCard: Sendable, Equatable, Decodable {
  public init(
    url: String,
    title: String,
    description: String,
    type: PreviewCardType,
    authorName: String,
    authorUrl: String,
    providerName: String,
    providerUrl: String,
    html: String,
    width: Int,
    height: Int,
    image: String?,
    embedUrl: String,
    blurhash: String?
  ) {
    self.url = url
    self.title = title
    self.description = description
    self.type = type
    self.authorName = authorName
    self.authorUrl = authorUrl
    self.providerName = providerName
    self.providerUrl = providerUrl
    self.html = html
    self.width = width
    self.height = height
    self.image = image
    self.embedUrl = embedUrl
    self.blurhash = blurhash
  }

  public var url: String
  public var title: String
  public var description: String
  public var type: PreviewCardType
  public var authorName: String
  public var authorUrl: String
  public var providerName: String
  public var providerUrl: String
  public var html: String
  public var width: Int
  public var height: Int
  public var image: String?
  public var embedUrl: String
  public var blurhash: String?
}

extension PreviewCard {
  /// PreviewCard.Type
  ///
  /// [API documentation](https://docs.joinmastodon.org/entities/PreviewCard/#type)
  public enum PreviewCardType: String, Sendable, Equatable, Decodable {
    case link
    case photo
    case video
    case rich
  }
}
