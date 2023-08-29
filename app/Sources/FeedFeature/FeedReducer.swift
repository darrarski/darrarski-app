import ComposableArchitecture

public struct FeedReducer: Reducer {
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
