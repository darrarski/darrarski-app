/// Represents an application that interfaces with the REST API to access accounts or post statuses.
///
/// [API documentation](https://docs.joinmastodon.org/entities/Application/)
public struct Application: Sendable, Equatable, Decodable {
  public init(
    name: String,
    website: String?,
    vapidKey: String?,
    clientId: String?,
    clientSecret: String?
  ) {
    self.name = name
    self.website = website
    self.vapidKey = vapidKey
    self.clientId = clientId
    self.clientSecret = clientSecret
  }

  public var name: String
  public var website: String?
  public var vapidKey: String?
  public var clientId: String?
  public var clientSecret: String?
}
