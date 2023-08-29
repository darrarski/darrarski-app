import ComposableArchitecture
import XCTest
@testable import AppFeature

@MainActor
final class AppReducerTests: XCTestCase {
  func testTask() async {
    let store = TestStore(initialState: AppReducer.State()) {
      AppReducer()
    }

    await store.finish()
  }
}
