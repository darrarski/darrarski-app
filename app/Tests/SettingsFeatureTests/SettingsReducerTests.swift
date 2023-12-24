import ComposableArchitecture
import XCTest
@testable import SettingsFeature

@MainActor
final class SettingsReducerTests: XCTestCase {
  func testAppTheme() async {
    let store = TestStore(initialState: SettingsReducer.State()) {
      SettingsReducer()
    }
    await store.send(.view(.tintColorChanged(.red))) {
      $0.theme.tintColor = .red
    }
    await store.send(.view(.colorSchemeChanged(.light))) {
      $0.theme.colorScheme = .light
    }
    await store.send(.view(.resetThemeTapped)) {
      $0.theme = .default
    }
  }
}
