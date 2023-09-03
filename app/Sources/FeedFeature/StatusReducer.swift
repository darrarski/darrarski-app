import ComposableArchitecture
import Foundation
import Mastodon

public struct StatusReducer: Reducer, Sendable {
  public struct State: Equatable, Identifiable {
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
      case cardTapped(PreviewCard)
      case linkTapped(URL)
    }
  }

  public init() {}

  @Dependency(\.openURL) var openURL

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.cardTapped(let card)):
        return .run { _ in
          if let url = URL(string: card.url) {
            await openURL(url)
          }
        }

      case .view(.linkTapped(let url)):
        return .run { _ in await openURL(url) }
      }
    }
  }
}
