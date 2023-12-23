import ComposableArchitecture
import XCTest
@testable import AppShared

@MainActor
final class AppThemeTests: XCTestCase {
  func testReset() async {
    let store = TestStore(initialState: AppTheme(
      tintColor: .red,
      colorScheme: .dark
    )) {
      AppThemeReducer()
    }
    await store.send(.reset) {
      $0 = .default
    }
  }
}
