import ComposableArchitecture
import Foundation

public struct ContactReducer: Reducer, Sendable {
  public struct State: Equatable {
    public init(
      contact: Contact? = nil,
      isLoading: Bool = false
    ) {
      self.contact = contact
      self.isLoading = isLoading
    }

    var contact: Contact?
    var isLoading: Bool
  }

  public enum Action: Equatable, Sendable {
    case fetchContact
    case fetchContactResult(TaskResult<Contact>)
    case view(View)

    public enum View: Equatable, Sendable {
      case refreshButtonTapped
      case refreshTask
      case task
    }
  }

  public init() {}

  @Dependency(\.contactProvider) var contactProvider

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      enum CancelId { case fetchGravatar }

      switch action {
      case .fetchContact:
        state.isLoading = true
        return .run { send in
          let result = await TaskResult {
            try await contactProvider.fetch()
          }
          await send(.fetchContactResult(result))
        }
        .cancellable(id: CancelId.fetchGravatar, cancelInFlight: true)

      case .fetchContactResult(let result):
        state.isLoading = false
        switch result {
        case .success(let contact):
          state.contact = contact

        case .failure(_):
          break
        }
        return .none

      case .view(.refreshButtonTapped):
        return .send(.fetchContact)

      case .view(.refreshTask):
        return .send(.fetchContact)

      case .view(.task):
        return .send(.fetchContact)
      }
    }
  }
}
