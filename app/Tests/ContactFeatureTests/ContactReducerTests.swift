import ComposableArchitecture
import XCTest
@testable import ContactFeature

@MainActor
final class ContactReducerTests: XCTestCase {
  func testFetchGravatar() async {
    let didFetchEmails = ActorIsolated<[String]>([])

    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.gravatar.fetch = { @Sendable email in
        await didFetchEmails.withValue { $0.append(email) }
        return .preview
      }
    }

    await store.send(.fetchGravatar) {
      $0.isLoading = true
    }
    await didFetchEmails.withValue {
      XCTAssertNoDifference($0, ["dariusz@darrarski.pl"])
    }
    await store.receive(.fetchGravatarResult(.success(.preview))) {
      $0.isLoading = false
      $0.gravatar = .preview
    }
  }

  func testFetchGravatarFailure() async {
    let error = NSError(domain: "", code: 0)
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.gravatar.fetch = { @Sendable _ in throw error }
    }

    await store.send(.fetchGravatar) {
      $0.isLoading = true
    }
    await store.receive(.fetchGravatarResult(.failure(error))) {
      $0.isLoading = false
    }
  }

  func testViewTask() async {
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.gravatar.fetch = { @Sendable _ in .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.task))
    await store.receive(.fetchGravatar)
  }

  func testViewRefreshTask() async {
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.gravatar.fetch = { @Sendable _ in .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshTask))
    await store.receive(.fetchGravatar)

  }

  func testViewRefreshButtonTapped() async {
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.gravatar.fetch = { @Sendable _ in .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshButtonTapped))
    await store.receive(.fetchGravatar)
  }
}
