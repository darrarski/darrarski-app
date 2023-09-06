import Dependencies
import Foundation

extension Client: DependencyKey {
  public static let liveValue = Client(
    getAccountStatuses: GetAccountStatuses { query in
      @Dependency(\.urlSession) var urlSession

      var urlComponents = URLComponents()
      urlComponents.scheme = "https"
      urlComponents.host = "mastodon.social"
      urlComponents.path = "/api/v1/accounts/\(query.accountId)/statuses"
      var queryItems: [URLQueryItem] = []
      if let limit = query.limit {
        queryItems.append(URLQueryItem(
          name: "limit",
          value: "\(limit)"
        ))
      }
      if let excludeReplies = query.excludeReplies {
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
      var request = URLRequest(url: url)
      request.httpMethod = "GET"

      let (data, response) = try await urlSession.data(for: request)
      let statusCode = (response as? HTTPURLResponse)?.statusCode
      guard let statusCode, (200..<300).contains(statusCode) else {
        throw ErrorResponse(statusCode: statusCode, data: data)
      }

      let decoder = JSONDecoder.mastodon
      let statuses = try decoder.decode([Status].self, from: data)

      return statuses
    }
  )
}
