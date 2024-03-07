import ComposableArchitecture
import XCTest
@testable import ContactFeature

final class ContactReducerTests: XCTestCase {
  @MainActor func testFetchContact() async {
    let clock = TestClock()
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.continuousClock = clock
      $0.contactProvider.fetch = { .preview }
    }

    await store.send(.fetchContact) {
      $0.isLoading = true
    }
    await clock.advance(by: .seconds(0.5))
    await store.receive(\.fetchContactResult.success) {
      $0.isLoading = false
      $0.contact = .preview
    }
  }

  @MainActor func testFetchContactFailure() async {
    let error = NSError(domain: "", code: 0)
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.contactProvider.fetch = { throw error }
    }

    await store.send(.fetchContact) {
      $0.isLoading = true
    }
    await store.receive(\.fetchContactResult.failure) {
      $0.isLoading = false
    }
  }

  @MainActor func testViewTask() async {
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.contactProvider.fetch = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.task))
    await store.receive(\.fetchContact)
  }

  @MainActor func testViewRefreshTask() async {
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.contactProvider.fetch = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshTask))
    await store.receive(\.fetchContact)

  }

  @MainActor func testViewRefreshButtonTapped() async {
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.contactProvider.fetch = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshButtonTapped))
    await store.receive(\.fetchContact)
  }

  @MainActor func testViewLinkButtonTapped() async {
    let link = Contact.Link(
      id: "",
      title: "",
      url: URL(filePath: "test"),
      iconURL: nil,
      target: .system
    )
    let didOpenURL = ActorIsolated<[URL]>([])
    let store = TestStore(initialState: ContactReducer.State()) {
      ContactReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.linkButtonTapped(link)))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [link.url])
    }
  }
}
