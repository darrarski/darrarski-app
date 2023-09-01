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
    accountId: String
  ) async throws -> [Status] {
    try await run(Query(
      accountId: accountId
    ))
  }
}

extension GetAccountStatuses {
  public struct Query: Equatable {
    public init(accountId: String) {
      self.accountId = accountId
    }

    public var accountId: String
  }
}
