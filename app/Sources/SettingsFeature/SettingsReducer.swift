import AppShared
import ComposableArchitecture

@Reducer
public struct SettingsReducer: Reducer {
  @ObservableState
  public struct State: Equatable {
    public init(
      theme: AppTheme = .default
    ) {
      self.theme = theme
    }

    public internal(set) var theme: AppTheme
  }

  public enum Action {
    case theme(AppThemeReducer.Action)
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Scope(state: \.theme, action: \.theme) {
      AppThemeReducer()
    }
  }
}
