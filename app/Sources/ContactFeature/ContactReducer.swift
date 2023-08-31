import ComposableArchitecture
import Foundation

public struct ContactReducer: Reducer, Sendable {
  public struct State: Equatable {
    public init(
      gravatar: GravatarJSON? = nil,
      isLoading: Bool = false
    ) {
      self.gravatar = gravatar
      self.isLoading = isLoading
    }

    var gravatar: GravatarJSON?
    var isLoading: Bool
  }

  public enum Action: Equatable, Sendable {
    case fetchGravatar
    case fetchGravatarResult(TaskResult<GravatarJSON>)
    case view(View)

    public enum View: Equatable, Sendable {
      case refreshButtonTapped
      case refreshTask
      case task
    }
  }

  public init() {}

  @Dependency(\.gravatar) var gravatar

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      enum CancelId { case fetchGravatar }

      switch action {
      case .fetchGravatar:
        state.isLoading = true
        return .run { send in
          let result = await TaskResult {
            try await gravatar.fetch(
              email: "dariusz@darrarski.pl"
            )
          }
          await send(.fetchGravatarResult(result))
        }
        .cancellable(id: CancelId.fetchGravatar, cancelInFlight: true)

      case .fetchGravatarResult(let result):
        state.isLoading = false
        switch result {
        case .success(let json):
          state.gravatar = json

        case .failure(_):
          break
        }
        return .none

      case .view(.refreshButtonTapped):
        return .send(.fetchGravatar)

      case .view(.refreshTask):
        return .send(.fetchGravatar)

      case .view(.task):
        return .send(.fetchGravatar)
      }
    }
  }
}
