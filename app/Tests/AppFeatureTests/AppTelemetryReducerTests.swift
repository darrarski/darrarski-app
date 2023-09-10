import ComposableArchitecture
import ContactFeature
import Mastodon
import ProjectsFeature
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
        case eight([EightAction])

        enum SixthAction: Equatable {
          case seventh
        }

        enum EightAction: Equatable {
          case ninth
          case tenth
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

    await store.send(.eight([.ninth, .tenth]))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.eight(Array)"
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

  func testActionWithContactLink() async {
    struct ExampleReducer: Reducer {
      struct State: Equatable {}

      enum Action: Equatable {
        case link(Contact.Link)
        case linkID(Contact.Link.ID)
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

    await store.send(.link(.init(
      id: "test-1",
      title: "Test Title",
      url: URL(filePath: "test.url"),
      iconURL: nil,
      target: .system
    )))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.link(Contact.Link)",
      payload: ["contact.link.id": "test-1"]
    )])
    signals.setValue([])

    await store.send(.linkID(.init(rawValue: "test-2")))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.linkID(Contact.Link.ID)",
      payload: ["contact.link.id": "test-2"]
    )])
    signals.setValue([])
  }

  func testActionWithProject() async {
    struct ExampleReducer: Reducer {
      struct State: Equatable {}

      enum Action: Equatable {
        case project(Project)
        case projectID(Project.ID)
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

    await store.send(.project(.init(
      date: Date(timeIntervalSince1970: 0),
      type: "Type",
      name: "Name",
      tags: [],
      url: nil
    )))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.project(Project)",
      payload: ["project.id": "1970-01-01 Name"]
    )])
    signals.setValue([])

    await store.send(.projectID(.init(
      date: Date(timeIntervalSince1970: 0),
      name: "Name"
    )))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.projectID(Project.ID)",
      payload: ["project.id": "1970-01-01 Name"]
    )])
    signals.setValue([])
  }

  func testActionWithMastodonStatus() async {
    struct ExampleReducer: Reducer {
      struct State: Equatable {}

      enum Action: Equatable {
        case status(Mastodon.Status)
        case statusID(Mastodon.Status.ID)
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
    let status = [Status].preview.first!

    await store.send(.status(status))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.status(Status)",
      payload: ["mastodon.status.id": status.id.rawValue]
    )])
    signals.setValue([])

    await store.send(.statusID(status.id))
    XCTAssertNoDifference(signals.value, [.init(
      type: "\(Self.self).ExampleReducer.Action.statusID(Status.ID)",
      payload: ["mastodon.status.id": status.id.rawValue]
    )])
    signals.setValue([])
  }
}
