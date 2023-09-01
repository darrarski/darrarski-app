import Dependencies
import Foundation
import XCTestDynamicOverlay

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

extension Client: TestDependencyKey {
  public static let testValue = Client(
    getAccountStatuses: GetAccountStatuses(
      run: unimplemented("\(Self.self).getAccountStatuses.run")
    )
  )

  public static let previewValue = Client(
    getAccountStatuses: .init { _ in
      try await Task.sleep(for: .seconds(1))
      return .preview
    }
  )
}

extension DependencyValues {
  public var mastodon: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}
