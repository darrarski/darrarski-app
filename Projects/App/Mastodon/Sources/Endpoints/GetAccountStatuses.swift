import DependenciesMacros
import Foundation

/// Get account’s statuses
///
/// [API documentation](https://docs.joinmastodon.org/methods/accounts/#statuses)
@Endpoint
public struct GetAccountStatuses: Sendable {
  public struct Request: Equatable, Sendable {
    public init(
      accountId: String,
      limit: Int? = nil,
      excludeReplies: Bool? = nil
    ) {
      self.accountId = accountId
      self.limit = limit
      self.excludeReplies = excludeReplies
    }

    public var accountId: String
    public var limit: Int?
    public var excludeReplies: Bool?
  }

  public typealias Response = [Status]
}

extension GetAccountStatuses: HTTPEndpoint {
  static func urlRequest(for request: Request) throws -> URLRequest {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "mastodon.social"
    urlComponents.path = "/api/v1/accounts/\(request.accountId)/statuses"
    var queryItems: [URLQueryItem] = []
    if let limit = request.limit {
      queryItems.append(URLQueryItem(
        name: "limit",
        value: "\(limit)"
      ))
    }
    if let excludeReplies = request.excludeReplies {
      queryItems.append(URLQueryItem(
        name: "exclude_replies",
        value: "\(excludeReplies)"
      ))
    }
    if !queryItems.isEmpty {
      urlComponents.queryItems = queryItems
    }
    guard let url = urlComponents.url else {
      throw RequestBuildingError()
    }
    var urlRequest = URLRequest(url: url)
    urlRequest.cachePolicy = .reloadRevalidatingCacheData
    urlRequest.httpMethod = "GET"
    return urlRequest
  }
}
