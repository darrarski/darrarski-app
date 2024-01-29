import Dependencies
import Foundation

/// Mastodon API
///
/// [API documentation](https://docs.joinmastodon.org/client/intro/)
public struct Client: Sendable {
  public init(
    getAccountStatuses: GetAccountStatuses
  ) {
    self.getAccountStatuses = getAccountStatuses
  }

  public var getAccountStatuses: GetAccountStatuses
}

extension Client: DependencyKey {
  public static let testValue = Client(
    getAccountStatuses: GetAccountStatuses()
  )
  public static let previewValue = Client(
    getAccountStatuses: .init { _ in
      try await Task.sleep(for: .seconds(1))
      return .preview
    }
  )
  public static let liveValue = Client(
    getAccountStatuses: .live
  )
}

extension DependencyValues {
  public var mastodon: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}
