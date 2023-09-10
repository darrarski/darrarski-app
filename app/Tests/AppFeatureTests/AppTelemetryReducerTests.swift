import ComposableArchitecture
import XCTest
@testable import AppFeature

@MainActor
final class AppTelemetryReducerTests: XCTestCase {
  func testActionSignals() async {
    struct ExampleReducer: Reducer {
      struct State: Equatable {}

      enum Action: Equatable {
        case first
        case second(String)
        case third(Int, String)
        case fourth(number: Int, text: String)
        case fifth(String?)
        case sixth(SixthAction)

        enum SixthAction: Equatable {
          case seventh
        }
      }
      
      var body: some ReducerOf<Self> {
        EmptyReducer()
      }
    }
    let signals = LockIsolated<[AppTelemetrySignal]>([])
    let store = TestStore(initialState: ExampleReducer.State()) {
      ExampleReducer()
      AppTelemetryReducer()
    } withDependencies: {
      $0.appTelemetry.send = { @Sendable signal in
        signals.withValue { $0.append(signal) }
      }
    }

    await store.send(.first)
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.first"
    )])
    signals.setValue([])

    await store.send(.second("test"))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.second(String)"
    )])
    signals.setValue([])

    await store.send(.third(7, "seven"))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.third(Int, String)"
    )])
    signals.setValue([])

    await store.send(.fourth(number: 7, text: "seven"))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.fourth(number: Int, text: String)"
    )])
    signals.setValue([])

    await store.send(.fifth("test"))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.fifth(.some(String))"
    )])
    signals.setValue([])

    await store.send(.fifth(nil))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.fifth(.none)"
    )])
    signals.setValue([])

    await store.send(.sixth(.seventh))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.sixth(.seventh)"
    )])
    signals.setValue([])
  }

  func testFailureActionSignals() async {
    struct ExampleReducer: Reducer {
      struct State: Equatable {}

      enum Action: Equatable {
        case first(TaskResult<String>)
        case second(NSError, NSError, NSError)
      }

      var body: some ReducerOf<Self> {
        EmptyReducer()
      }
    }
    let signals = LockIsolated<[AppTelemetrySignal]>([])
    let store = TestStore(initialState: ExampleReducer.State()) {
      ExampleReducer()
      AppTelemetryReducer()
    } withDependencies: {
      $0.appTelemetry.send = { @Sendable signal in
        signals.withValue { $0.append(signal) }
      }
    }

    let nsError = NSError(domain: "test", code: 1337)
    await store.send(.first(.failure(nsError)))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.first(.failure(NSError))",
      payload: [
        "error.localizedDescription": nsError.localizedDescription,
        "error.domain": nsError.domain,
        "error.code": "\(nsError.code)",
      ]
    )])
    signals.setValue([])

    struct StructError: Error { var value = 44 }
    let structError = StructError()
    await store.send(.first(.failure(structError)))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.first(.failure(\(Self.self).StructError))",
      payload: [
        "error.localizedDescription": structError.localizedDescription,
        "error.domain": (structError as NSError).domain,
        "error.code": "\((structError as NSError).code)",
      ]
    )])
    signals.setValue([])

    enum EnumError: Error { case somethingWentWrong }
    let enumError = EnumError.somethingWentWrong
    await store.send(.first(.failure(enumError)))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.first(.failure(\(Self.self).EnumError.somethingWentWrong))",
      payload: [
        "error.localizedDescription": enumError.localizedDescription,
        "error.domain": (enumError as NSError).domain,
        "error.code": "\((enumError as NSError).code)",
      ]
    )])
    signals.setValue([])

    let nsError1 = NSError(domain: "test1", code: 1)
    let nsError2 = NSError(domain: "test2", code: 2)
    let nsError3 = NSError(domain: "test3", code: 3)
    await store.send(.second(nsError1, nsError2, nsError3))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.second(NSError, NSError, NSError)",
      payload: [
        "error.localizedDescription": nsError1.localizedDescription,
        "error.domain": nsError1.domain,
        "error.code": "\(nsError1.code)",
        "error.localizedDescription_1": nsError2.localizedDescription,
        "error.domain_1": nsError2.domain,
        "error.code_1": "\(nsError2.code)",
        "error.localizedDescription_2": nsError3.localizedDescription,
        "error.domain_2": nsError3.domain,
        "error.code_2": "\(nsError3.code)",
      ]
    )])
    signals.setValue([])
  }
}
