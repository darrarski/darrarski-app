import Dependencies
import DependenciesMacros
import Foundation

public struct HTTPClient: Sendable {
  @DependencyEndpoint
  public var dataForRequest: @Sendable (URLRequest) async throws -> (Data, URLResponse)

  public func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
    try await dataForRequest(urlRequest)
  }
}

extension HTTPClient: DependencyKey {
  public static let testValue = HTTPClient()
  public static let liveValue = HTTPClient(
    dataForRequest: { request in
      @Dependency(\.urlSession) var urlSession
      return try await urlSession.data(for: request)
    }
  )
}

extension DependencyValues {
  public var httpClient: HTTPClient {
    get { self[HTTPClient.self] }
    set { self[HTTPClient.self] = newValue }
  }
}
