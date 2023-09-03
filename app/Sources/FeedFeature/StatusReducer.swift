import ComposableArchitecture
import Foundation
import Mastodon

public struct StatusReducer: Reducer, Sendable {
  public struct State: Equatable, Sendable, Identifiable {
    public init(
      status: Status
    ) {
      self.status = status
    }

    public var id: Status.ID { status.id }
    var status: Status
    var displayStatus: Status { status.reblog?.value ?? status }
  }

  public enum Action: Equatable, Sendable {
    case view(View)

    public enum View: Equatable, Sendable {
      case linkTapped(URL)
      case previewCardTapped
    }
  }

  public init() {}

  @Dependency(\.openURL) var openURL

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.linkTapped(let url)):
        return .run { _ in await openURL(url) }

      case .view(.previewCardTapped):
        return .run { [state] _ in
          if let url = (state.status.card?.url).flatMap(URL.init) {
            await openURL(url)
          }
        }
      }
    }
  }
}
