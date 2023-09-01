import ComposableArchitecture
import Mastodon
import XCTest
@testable import FeedFeature

@MainActor
final class StatusReducerTests: XCTestCase {
  func testTask() async {
    let store = TestStore(initialState: StatusReducer.State(
      status: [Status].preview[0]
    )) {
      StatusReducer()
    }

    await store.finish()
  }
}
