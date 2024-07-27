import Dependencies
import DependenciesMacros
import Foundation
import XCTestDynamicOverlay

@DependencyClient
struct ProjectsProvider: Sendable {
  struct InvalidURLError: Error {}

  struct ResponseError: Error {
    var statusCode: Int?
    var data: Data
  }

  struct InvalidResponseError: Error {
    var statusCode: Int
    var data: Data
  }

  var fetchInfo: @Sendable () async throws -> ProjectsInfo
  var fetchProjects: @Sendable () async throws -> [Project]
}

extension DependencyValues {
  var projectsProvider: ProjectsProvider {
    get { self[ProjectsProvider.self] }
    set { self[ProjectsProvider.self] = newValue }
  }
}

extension ProjectsProvider: TestDependencyKey {
  static let testValue = ProjectsProvider()
  static let previewValue = ProjectsProvider(
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
  static let liveValue = ProjectsProvider(
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
