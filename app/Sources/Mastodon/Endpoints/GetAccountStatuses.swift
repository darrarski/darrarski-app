/// Get account’s statuses
///
/// [API documentation](https://docs.joinmastodon.org/methods/accounts/#statuses)
public struct GetAccountStatuses: Sendable {
  public typealias Run = @Sendable (Query) async throws -> [Status]

  public init(run: @escaping GetAccountStatuses.Run) {
    self.run = run
  }

  public var run: Run

  public func callAsFunction(_ query: Query) async throws -> [Status] {
    try await run(query)
  }

  public func callAsFunction(
    accountId: String,
    limit: Int? = nil,
    excludeReplies: Bool? = nil
  ) async throws -> [Status] {
    try await run(Query(
      accountId: accountId,
      limit: limit,
      excludeReplies: excludeReplies
    ))
  }
}

extension GetAccountStatuses {
  public struct Query: Equatable, Sendable {
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
}
