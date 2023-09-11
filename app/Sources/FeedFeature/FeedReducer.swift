import ComposableArchitecture
import Foundation
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
      case seeMoreButtonTapped
      case task
    }
  }

  public init() {}

  @Dependency(\.continuousClock) var clock
  @Dependency(\.mastodon) var mastodon
  @Dependency(\.openURL) var openURL
  static let mastodonAccountId = "108131495937150285"
  static let mastodonAccountURL = URL(string: "https://mastodon.social/@darrarski")!

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      enum CancelId { case fetchStatuses }

      switch action {
      case .fetchStatuses:
        state.isLoading = true
        return .run { send in
          try await clock.sleep(for: .seconds(0.5))
          let result = await TaskResult {
            try await mastodon.getAccountStatuses(
              accountId: Self.mastodonAccountId,
              limit: 40,
              excludeReplies: true
            )
          }
          await send(.fetchStatusesResult(result))
        }
        .cancellable(id: CancelId.fetchStatuses, cancelInFlight: true)

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

      case .view(.seeMoreButtonTapped):
        return .run { send in
          await openURL(Self.mastodonAccountURL)
        }

      case .view(.task):
        return .send(.fetchStatuses)
      }
    }
    .forEach(\.statuses, action: /Action.status(id:action:)) {
      StatusReducer()
    }
  }
}
