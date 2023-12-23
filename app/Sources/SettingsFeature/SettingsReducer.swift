import AppShared
import ComposableArchitecture

@Reducer
public struct SettingsReducer: Reducer {
  @ObservableState
  public struct State: Equatable {
    public init() {}
  }

  public enum Action: Equatable {}

  public init() {}

  public var body: some ReducerOf<Self> {
    EmptyReducer()
  }
}
