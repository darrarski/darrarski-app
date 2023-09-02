/// Represents a file or media attachment that can be added to a status.
///
/// [API documentation](https://docs.joinmastodon.org/entities/MediaAttachment/)
public struct MediaAttachment: Sendable, Equatable, Identifiable, Decodable {
  public init(
    id: String,
    type: MediaAttachmentType,
    url: String,
    previewUrl: String?,
    remoteUrl: String?,
    meta: JSONObject,
    description: String?,
    blurhash: String
  ) {
    self.id = id
    self.type = type
    self.url = url
    self.previewUrl = previewUrl
    self.remoteUrl = remoteUrl
    self.meta = meta
    self.description = description
    self.blurhash = blurhash
  }

  public var id: String
  public var type: MediaAttachmentType
  public var url: String
  public var previewUrl: String?
  public var remoteUrl: String?
  public var meta: JSONObject
  public var description: String?
  public var blurhash: String
}

extension MediaAttachment {
  /// MediaAttachment.Type
  ///
  /// [API documentation](https://docs.joinmastodon.org/entities/MediaAttachment/#type)
  public enum MediaAttachmentType: String, Sendable, Equatable, Decodable {
    case unknown
    case image
    case gifv
    case video
    case audio
  }
}
