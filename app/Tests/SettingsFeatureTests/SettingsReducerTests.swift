import ComposableArchitecture
import XCTest
@testable import SettingsFeature

@MainActor
final class SettingsReducerTests: XCTestCase {
  func testExample() async {
    let store = TestStore(initialState: SettingsReducer.State()) {
      SettingsReducer()
    }
    await store.finish()
  }
}
