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

    let nsError = NSError(domain: "test", code: 1337)
    await store.send(.contact(.fetchContactResult(.failure(nsError))))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.fetchContactResult(.failure(NSError)))",
      payload: [
        "error.localizedDescription": nsError.localizedDescription,
        "error.domain": nsError.domain,
        "error.code": "\(nsError.code)",
      ]
    )])
    signals.setValue([])

    struct StructError: Error { var value = 44 }
    let structError = StructError()
    await store.send(.contact(.fetchContactResult(.failure(structError))))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.fetchContactResult(.failure(\(Self.self).StructError)))",
      payload: [
        "error.localizedDescription": structError.localizedDescription,
        "error.domain": (structError as NSError).domain,
        "error.code": "\((structError as NSError).code)",
      ]
    )])
    signals.setValue([])

    enum EnumError: Error { case failure }
    let enumError = EnumError.failure
    await store.send(.contact(.fetchContactResult(.failure(enumError))))
    XCTAssertNoDifference(signals.value, [.init(
      type: "AppReducer.Action.contact(.fetchContactResult(.failure(\(Self.self).EnumError.failure)))",
      payload: [
        "error.localizedDescription": enumError.localizedDescription,
        "error.domain": (enumError as NSError).domain,
        "error.code": "\((enumError as NSError).code)",
      ]
    )])
    signals.setValue([])
  }
}
