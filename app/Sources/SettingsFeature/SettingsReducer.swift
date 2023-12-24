import AppShared
import ComposableArchitecture
import struct SwiftUI.Color

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

  public enum Action: ViewAction {
    case view(View)

    @CasePathable
    public enum View {
      case tintColorChanged(Color)
      case colorSchemeChanged(AppTheme.ColorScheme)
      case resetThemeTapped
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.tintColorChanged(let color)):
        state.theme.tintColor = color
        return .none

      case .view(.colorSchemeChanged(let colorScheme)):
        state.theme.colorScheme = colorScheme
        return .none

      case .view(.resetThemeTapped):
        state.theme = .default
        return .none
      }
    }
  }
}
