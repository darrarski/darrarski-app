import ComposableArchitecture
import Foundation
import Mastodon

@Reducer
public struct FeedReducer: Reducer, Sendable {
  @ObservableState
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

  public enum Action: Sendable, ViewAction {
    case fetchStatuses
    case fetchStatusesResult(Result<[Mastodon.Status], any Error>)
    case status(IdentifiedActionOf<StatusReducer>)
    case view(View)

    @CasePathable
    public enum View: Sendable {
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
    Reduce<State, Action> { state, action in
      enum CancelId { case fetchStatuses }

      switch action {
      case .fetchStatuses:
        state.isLoading = true
        return .run { send in
          try await clock.sleep(for: .seconds(0.5))
          let result = await Result {
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
          state.statuses = IdentifiedArray(
            uniqueElements: statuses.map { status in
              var state = state.statuses[id: status.id] ?? StatusReducer.State(status: status)
              state.status = status
              return state
            }
          )
          return .none

        case .failure(_):
          return .none
        }

      case .status(_):
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
    .forEach(\.statuses, action: \.status) {
      StatusReducer()
    }
  }
}
