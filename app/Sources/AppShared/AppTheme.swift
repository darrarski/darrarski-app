import ComposableArchitecture
import SwiftUI

@ObservableState
public struct AppTheme: Sendable, Equatable {
  public enum ColorScheme: Sendable, Equatable, CaseIterable {
    case light
    case dark
    case system
  }

  public init(
    tintColor: Color,
    colorScheme: ColorScheme
  ) {
    self.tintColor = tintColor
    self.colorScheme = colorScheme
  }

  public static var `default`: AppTheme {
    AppTheme(
      tintColor: Color(.appTint),
      colorScheme: .system
    )
  }

  public var tintColor: Color
  public var colorScheme: ColorScheme
}

@Reducer
public struct AppThemeReducer: Reducer {
  public typealias State = AppTheme

  public enum Action: BindableAction {
    case binding(_ action: BindingAction<State>)
    case reset
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none

      case .reset:
        state = .default
        return .none
      }
    }
  }
}

public typealias AppThemeStore = StoreOf<AppThemeReducer>

extension AppThemeStore {
  public static let preview = AppThemeStore(initialState: .default) {
    AppThemeReducer()
  }
}

extension ColorScheme {
  public init?(_ scheme: AppTheme.ColorScheme) {
    switch scheme {
    case .light: self = .light
    case .dark: self = .dark
    case .system: return nil
    }
  }
}

struct AppThemeWrapper<Content: View>: View {
  var content: Content
  let store: AppThemeStore

  var body: some View {
    content
      .tint(store.tintColor)
      .preferredColorScheme(ColorScheme(store.colorScheme))
      .environment(store)
  }
}

struct AppThemeViewModifier: ViewModifier {
  let store: AppThemeStore

  func body(content: Content) -> some View {
    AppThemeWrapper(content: content, store: store)
  }
}

extension View {
  public func appTheme(_ store: AppThemeStore) -> some View {
    modifier(AppThemeViewModifier(store: store))
  }
}
