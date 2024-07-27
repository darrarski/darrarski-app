import ComposableArchitecture
import XCTest
@testable import AppFeature

final class AppReducerTests: XCTestCase {
  @MainActor func testSelectingSections() async {
    let store = TestStore(initialState: AppReducer.State()) {
      AppReducer()
    }

    await store.send(.view(.sectionSelected(.feed))) {
      $0.selectedSection = .feed
    }
    await store.send(.view(.sectionSelected(nil))) {
      $0.selectedSection = .contact
    }
  }
}
