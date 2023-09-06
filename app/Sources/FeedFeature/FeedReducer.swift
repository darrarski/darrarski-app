import ComposableArchitecture
import Mastodon

public struct FeedReducer: Reducer, Sendable {
  public struct State: Equatable {
    public init(
      statuses: IdentifiedArrayOf<StatusReducer.State> = [],
      isLoading: Bool = false
    ) {
      self.statuses = statuses
      self.isLoading = isLoading
    }

    public var statuses: IdentifiedArrayOf<StatusReducer.State>
    public var isLoading: Bool
  }

  public enum Action: Equatable, Sendable {
    case fetchStatuses
    case fetchStatusesResult(TaskResult<[Mastodon.Status]>)
    case status(id: StatusReducer.State.ID, action: StatusReducer.Action)
    case view(View)

    public enum View: Equatable, Sendable {
      case refreshButtonTapped
      case refreshTask
      case task
    }
  }

  public init() {}

  @Dependency(\.mastodon) var mastodon
  static let mastodonAccountId = "108131495937150285"

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      enum CancelId { case fetchStatuses }

      switch action {
      case .fetchStatuses:
        state.isLoading = true
        return .run { send in
          let result = await TaskResult {
            try await mastodon.getAccountStatuses(
              accountId: Self.mastodonAccountId,
              limit: 40,
              excludeReplies: true
            )
          }
          await send(.fetchStatusesResult(result))
        }

      case .fetchStatusesResult(let result):
        state.isLoading = false
        switch result {
        case .success(let statuses):
          state.statuses = .init(
            uniqueElements: statuses.map { StatusReducer.State(status:$0) }
          )

        case .failure(_):
          break
        }
        return .none

      case .status(_, _):
        return .none

      case .view(.refreshButtonTapped):
        return .send(.fetchStatuses)

      case .view(.refreshTask):
        return .send(.fetchStatuses)

      case .view(.task):
        return .send(.fetchStatuses)
      }
    }
    .forEach(\.statuses, action: /Action.status(id:action:)) {
      StatusReducer()
    }
  }
}
