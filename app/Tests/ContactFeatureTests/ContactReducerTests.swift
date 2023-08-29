import ComposableArchitecture
import XCTest
@testable import ContactFeature

@MainActor
final class ContactReducerTests: XCTestCase {
  func testTask() async {
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    }

    await store.finish()
  }
}
