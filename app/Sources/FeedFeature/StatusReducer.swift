import ComposableArchitecture
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
  }

  public enum Action: Equatable, Sendable {
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
