import ComposableArchitecture
import XCTest
@testable import AppFeature

@MainActor
final class AppTelemetryReducerTests: XCTestCase {
  func testActionSignals() async {
    let signals = LockIsolated<[AppTelemetrySignal]>([])
    let store = TestStore(initialState: AppReducer.State()) {
      AppTelemetryReducerOf<AppReducer>()
    } withDependencies: {
      $0.appTelemetry.send = { @Sendable signal in
        signals.withValue { $0.append(signal) }
      }
    }

    await store.send(.view(.sectionSelected(.contact)))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.view(.sectionSelected(.some(.contact)))"
    )])
    signals.setValue([])

    await store.send(.view(.sectionSelected(.feed)))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.view(.sectionSelected(.some(.feed)))"
    )])
    signals.setValue([])

    await store.send(.view(.sectionSelected(.none)))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.view(.sectionSelected(.none))"
    )])
    signals.setValue([])

    await store.send(.contact(.view(.task)))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.view(.task))"
    )])
    signals.setValue([])

    await store.send(.contact(.fetchContact))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.fetchContact)"
    )])
    signals.setValue([])

    await store.send(.contact(.fetchContactResult(.success(.preview))))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.fetchContactResult(.success(Contact)))"
    )])
    signals.setValue([])

    await store.send(.contact(.fetchContactResult(.failure(NSError(domain: "test", code: 1337)))))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.fetchContactResult(.failure(NSError)))"
    )])
    signals.setValue([])

    struct StructError: Error { var value = 44 }
    await store.send(.contact(.fetchContactResult(.failure(StructError()))))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.fetchContactResult(.failure(\(Self.self).StructError)))"
    )])
    signals.setValue([])

    enum EnumError: Error { case failure }
    await store.send(.contact(.fetchContactResult(.failure(EnumError.failure))))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.fetchContactResult(.failure(\(Self.self).EnumError.failure)))"
    )])
    signals.setValue([])
  }
}
