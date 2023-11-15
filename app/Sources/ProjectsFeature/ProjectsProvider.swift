import Dependencies
import Foundation
import XCTestDynamicOverlay

public struct ProjectsProvider: Sendable {
  public typealias FetchInfo = @Sendable () async throws -> ProjectsInfo
  public typealias FetchProjects = @Sendable () async throws -> [Project]

  public init(
    fetchInfo: @escaping FetchInfo,
    fetchProjects: @escaping FetchProjects
  ) {
    self.fetchInfo = fetchInfo
    self.fetchProjects = fetchProjects
  }

  public var fetchInfo: FetchInfo
  public var fetchProjects: FetchProjects
}

extension DependencyValues {
  public var projectsProvider: ProjectsProvider {
    get { self[ProjectsProvider.self] }
    set { self[ProjectsProvider.self] = newValue }
  }
}

extension ProjectsProvider: TestDependencyKey {
  public static let testValue = ProjectsProvider(
    fetchInfo: unimplemented("\(Self.self).fetchInfo"),
    fetchProjects: unimplemented("\(Self.self).fetchProjects")
  )

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

  public struct InvalidResponseError: Error {
    public init(statusCode: Int, data: Data) {
      self.statusCode = statusCode
      self.data = data
    }
    
    public var statusCode: Int
    public var data: Data
  }

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
