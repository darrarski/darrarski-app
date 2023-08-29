import ComposableArchitecture
import XCTest
@testable import FeedFeature

@MainActor
final class FeedReducerTests: XCTestCase {
  func testTask() async {
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    }

    await store.finish()
  }
}
