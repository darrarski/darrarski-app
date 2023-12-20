import Dependencies
import DependenciesMacros
import Foundation
import XCTestDynamicOverlay

@DependencyClient
public struct ContactProvider: Sendable {
  public struct InvalidURLError: Error {
    public init() {}
  }

  public struct ResponseError: Error {
    public init(statusCode: Int?, data: Data) {
      self.statusCode = statusCode
      self.data = data
    }

    public var statusCode: Int?
    public var data: Data
  }

  public var fetch: @Sendable () async throws -> Contact
}

extension DependencyValues {
  public var contactProvider: ContactProvider {
    get { self[ContactProvider.self] }
    set { self[ContactProvider.self] = newValue }
  }
}

extension ContactProvider: DependencyKey {
  public static let testValue = ContactProvider()
  public static let previewValue = ContactProvider {
    try await Task.sleep(for: .seconds(1))
    return .preview
  }
  public static let liveValue = ContactProvider {
    @Dependency(\.urlSession) var urlSession

    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "app.darrarski.pl"
    urlComponents.path = "/contact.json"
    guard let url = urlComponents.url else {
      throw InvalidURLError()
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.cachePolicy = .reloadRevalidatingCacheData
    urlRequest.httpMethod = "GET"
    let (data, response) = try await urlSession.data(for: urlRequest)
    let statusCode = (response as? HTTPURLResponse)?.statusCode
    guard let statusCode, (200..<300).contains(statusCode) else {
      throw ResponseError(statusCode: statusCode, data: data)
    }
    let decoder = JSONDecoder()
    let contact = try decoder.decode(Contact.self, from: data)

    return contact
  }
}
