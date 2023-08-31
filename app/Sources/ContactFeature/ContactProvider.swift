import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct ContactProvider: Sendable {
  public typealias Fetch = @Sendable () async throws -> Contact

  public init(fetch: @escaping ContactProvider.Fetch) {
    self.fetch = fetch
  }

  public var fetch: Fetch
}

extension DependencyValues {
  public var contactProvider: ContactProvider {
    get { self[ContactProvider.self] }
    set { self[ContactProvider.self] = newValue }
  }
}

extension ContactProvider: TestDependencyKey {
  public static let testValue = ContactProvider(
    fetch: unimplemented("\(Self.self).fetch")
  )

  public static let previewValue = ContactProvider {
    .preview
  }
}

extension ContactProvider: DependencyKey {
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
