import ComposableArchitecture
import SwiftUI

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

extension ColorScheme {
  public init?(_ scheme: AppTheme.ColorScheme) {
    switch scheme {
    case .light: self = .light
    case .dark: self = .dark
    case .system: return nil
    }
  }
}

struct AppThemeEnvironmentKey: EnvironmentKey {
  static let defaultValue = AppTheme.default
}

extension EnvironmentValues {
  public var appTheme: AppTheme {
    get { self[AppThemeEnvironmentKey.self] }
    set { self[AppThemeEnvironmentKey.self] = newValue }
  }
}

extension View {
  public func appTheme(_ appTheme: AppTheme) -> some View {
    self
      .tint(appTheme.tintColor)
      .preferredColorScheme(ColorScheme(appTheme.colorScheme))
      .environment(\.appTheme, appTheme)
  }
}
