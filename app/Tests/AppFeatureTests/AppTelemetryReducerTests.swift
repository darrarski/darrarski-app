import ComposableArchitecture
import XCTest
@testable import AppFeature

@MainActor
final class AppTelemetryReducerTests: XCTestCase {
  func testActionSignals() async {
    let signals = LockIsolated<[String]>([])
    let store = TestStore(initialState: AppReducer.State()) {
      AppTelemetryReducerOf<AppReducer>()
    } withDependencies: {
      $0.appTelemetry.send = { signal in
        signals.withValue { $0.append(signal) }
      }
    }
    let actions: [AppReducer.Action] = [
      .view(.sectionSelected(.contact)),
      .view(.sectionSelected(.feed)),
      .view(.sectionSelected(.none)),
      .contact(.view(.task)),
      .contact(.fetchContact),
      .contact(.fetchContactResult(.success(.preview))),
      .contact(.fetchContactResult(.failure(NSError(domain: "test", code: 1337)))),
    ]
    for action in actions {
      await store.send(action)
    }
    XCTAssertNoDifference(signals.value, [
      "AppReducer.Action.view(.sectionSelected(.some(.contact)))",
      "AppReducer.Action.view(.sectionSelected(.some(.feed)))",
      "AppReducer.Action.view(.sectionSelected(.none))",
      "AppReducer.Action.contact(.view(.task))",
      "AppReducer.Action.contact(.fetchContact)",
      "AppReducer.Action.contact(.fetchContactResult(.success(Contact)))",
      "AppReducer.Action.contact(.fetchContactResult(.failure(NSError)))",
    ])
  }
}
