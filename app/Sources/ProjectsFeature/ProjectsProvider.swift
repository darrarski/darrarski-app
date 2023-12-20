import Dependencies
import DependenciesMacros
import Foundation
import XCTestDynamicOverlay

@DependencyClient
public struct ProjectsProvider: Sendable {
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

  public struct InvalidResponseError: Error {
    public init(statusCode: Int, data: Data) {
      self.statusCode = statusCode
      self.data = data
    }

    public var statusCode: Int
    public var data: Data
  }

  public var fetchInfo: @Sendable () async throws -> ProjectsInfo
  public var fetchProjects: @Sendable () async throws -> [Project]
}

extension DependencyValues {
  public var projectsProvider: ProjectsProvider {
    get { self[ProjectsProvider.self] }
    set { self[ProjectsProvider.self] = newValue }
  }
}

extension ProjectsProvider: DependencyKey {
  public static let testValue = ProjectsProvider()
  public static let previewValue = ProjectsProvider(
    fetchInfo: {
      try await Task.sleep(for: .seconds(0.5))
      return .preview
    },
    fetchProjects: {
      try await Task.sleep(for: .seconds(1))
      return .preview
    }
  )
  public static let liveValue = ProjectsProvider(
    fetchInfo: {
      @Dependency(\.urlSession) var urlSession

      var urlComponents = URLComponents()
      urlComponents.scheme = "https"
      urlComponents.host = "app.darrarski.pl"
      urlComponents.path = "/projects.md"
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
      guard let string = String(data: data, encoding: .utf8) else {
        throw InvalidResponseError(statusCode: statusCode, data: data)
      }
      let content = try AttributedString(appMarkdown: string)

      return ProjectsInfo(content: content)
    },
    fetchProjects: {
      @Dependency(\.urlSession) var urlSession

      var urlComponents = URLComponents()
      urlComponents.scheme = "https"
      urlComponents.host = "app.darrarski.pl"
      urlComponents.path = "/projects.json"
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
      let projects = try decoder.decode([Project].self, from: data)

      return projects
    }
  )
}
