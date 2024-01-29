import Dependencies
import Foundation

protocol HTTPEndpoint: Endpoint {
  static func urlRequest(for request: Request) throws -> URLRequest
  static func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse)
  static func validate(_ data: Data, _ urlResponse: URLResponse) throws
  static func decode(_ data: Data) throws -> Response
}

extension HTTPEndpoint {
  static var live: Self {
    var endpoint = Self.init()
    endpoint.send = { request in
      let urlRequest = try urlRequest(for: request)
      let (data, urlResponse) = try await data(for: urlRequest)
      try validate(data, urlResponse)
      return try decode(data)
    }
    return endpoint
  }
}

extension HTTPEndpoint {
  static func data(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
    @Dependency(\.httpClient) var httpClient
    return try await httpClient.data(for: urlRequest)
  }

  static func validate(_ data: Data, _ urlResponse: URLResponse) throws {
    let statusCode = (urlResponse as? HTTPURLResponse)?.statusCode
    guard let statusCode, (200..<300).contains(statusCode) else {
      throw ErrorResponse(statusCode: statusCode, data: data)
    }
  }

  static func decode(_ data: Data) throws -> Response where Response: Decodable {
    try JSONDecoder.mastodon.decode(Response.self, from: data)
  }
}
