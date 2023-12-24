import ComposableArchitecture
import Foundation

@Reducer
public struct ContactReducer: Reducer, Sendable {
  @ObservableState
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

  public enum Action: Sendable, ViewAction {
    case fetchContact
    case fetchContactResult(Result<Contact, Error>)
    case view(View)

    @CasePathable
    public enum View: Sendable {
      case linkButtonTapped(Contact.Link)
      case refreshButtonTapped
      case refreshTask
      case task
    }
  }

  public init() {}

  @Dependency(\.continuousClock) var clock
  @Dependency(\.contactProvider) var contactProvider
  @Dependency(\.openURL) var openURL

  public var body: some ReducerOf<Self> {
    Reduce<State, Action> { state, action in
      enum CancelId { case fetchGravatar }

      switch action {
      case .fetchContact:
        state.isLoading = true
        return .run { send in
          try await clock.sleep(for: .seconds(0.5))
          let result = await Result {
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

      case .view(.linkButtonTapped(let link)):
        return .run { _ in
          switch link.target {
          case .system:
            await openURL(link.url)
          }
        }

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
