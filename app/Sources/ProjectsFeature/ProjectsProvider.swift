import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct ProjectsProvider: Sendable {
  public typealias Fetch = @Sendable () async throws -> [Project]

  public init(fetch: @escaping Fetch) {
    self.fetch = fetch
  }

  public var fetch: Fetch
}

extension DependencyValues {
  public var projectsProvider: ProjectsProvider {
    get { self[ProjectsProvider.self] }
    set { self[ProjectsProvider.self] = newValue }
  }
}

extension ProjectsProvider: TestDependencyKey {
  public static let testValue = ProjectsProvider(
    fetch: unimplemented("\(Self.self).fetch")
  )

  public static let previewValue = ProjectsProvider {
    try await Task.sleep(for: .seconds(1))
    return .preview
  }
}

extension ProjectsProvider: DependencyKey {
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

  public static let liveValue = ProjectsProvider {
    @Dependency(\.urlSession) var urlSession

    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "app.darrarski.pl"
    urlComponents.path = "/projects.json"
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
    let projects = try decoder.decode([Project].self, from: data)

    return projects
  }
}
