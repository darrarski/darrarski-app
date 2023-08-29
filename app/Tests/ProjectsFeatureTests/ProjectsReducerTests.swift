import ComposableArchitecture
import XCTest
@testable import ProjectsFeature

@MainActor
final class ProjectsReducerTests: XCTestCase {
  func testTask() async {
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    }

    await store.finish()
  }
}
