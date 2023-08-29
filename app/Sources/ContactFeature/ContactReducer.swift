import ComposableArchitecture

public struct ContactReducer: Reducer {
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
