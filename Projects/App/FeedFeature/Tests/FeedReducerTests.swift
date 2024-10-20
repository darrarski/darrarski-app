import ComposableArchitecture
import Mastodon
import XCTest
@testable import FeedFeature

final class FeedReducerTests: XCTestCase {
  @MainActor func testFetchStatuses() async {
    let clock = TestClock()
    let didFetch = LockIsolated<[Mastodon.GetAccountStatuses.Request]>([])
    let didRenderStatusText = LockIsolated(0)
    let statuses = [Status].preview
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = clock
      $0.mastodon.getAccountStatuses.send = { request in
        didFetch.withValue { $0.append(request) }
        return statuses
      }
      $0.statusTextRenderer.render = {
        didRenderStatusText.withValue { $0 += 1 }
        return AttributedString($0)
      }
    }

    await store.send(.fetchStatuses) {
      $0.isLoading = true
    }
    await clock.advance(by: .seconds(0.5))
    expectNoDifference(didFetch.value, [.init(
      accountId: FeedReducer.mastodonAccountId,
      limit: 40,
      excludeReplies: true
    )])
    await store.receive(\.fetchStatusesResult.success) {
      $0.isLoading = false
      $0.statuses = .init(
        uniqueElements: statuses.map {
          StatusReducer.State(
            status: $0,
            text: AttributedString(($0.reblog?.value ?? $0).content)
          )
        }
      )
    }
    XCTAssertEqual(didRenderStatusText.value, statuses.count)
    didRenderStatusText.setValue(0)
    await store.send(.fetchStatuses) {
      $0.isLoading = true
    }
    await clock.advance(by: .seconds(0.5))
    await store.receive(\.fetchStatusesResult.success) {
      $0.isLoading = false
    }
    XCTAssertEqual(didRenderStatusText.value, 0)
  }

  @MainActor func testFetchStatusesFailure() async {
    let error = NSError(domain: "test", code: 1234)
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.mastodon.getAccountStatuses.send = { _ in throw error }
    }

    await store.send(.fetchStatuses) {
      $0.isLoading = true
    }
    await store.receive(\.fetchStatusesResult.failure) {
      $0.isLoading = false
    }
  }

  @MainActor func testFetchStatusesRenderingFailure() async {
    let clock = TestClock()
    let statuses = Array([Status].preview[0...2])
    struct Failure: Error, Equatable {
      var text: String
    }
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = clock
      $0.mastodon.getAccountStatuses.send = { _ in statuses }
      $0.statusTextRenderer.render = { text in
        if text == (statuses[1].reblog?.value ?? statuses[1]).content {
          throw Failure(text: text)
        }
        return AttributedString(text)
      }
    }

    await store.send(.fetchStatuses) {
      $0.isLoading = true
    }
    await clock.advance(by: .seconds(0.5))
    await store.receive { action in
      guard case .statusTextRenderingFailed(let id, let error) = action,
            let error = error as? Failure else {
        return false
      }
      return (id, error) == (
        statuses[1].id,
        Failure(text: (statuses[1].reblog?.value ?? statuses[1]).content)
      )
    }
    await store.receive(\.fetchStatusesResult.success) {
      $0.isLoading = false
      $0.statuses = .init(
        uniqueElements: statuses.map {
          var state = StatusReducer.State(status: $0)
          if state.status.id != statuses[1].id {
            state.text = AttributedString(($0.reblog?.value ?? $0).content)
          }
          return state
        }
      )
    }
  }

  @MainActor func testViewTask() async {
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.mastodon.getAccountStatuses.send = { _ in [] }
    }
    store.exhaustivity = .off

    await store.send(.view(.task))
    await store.receive(\.fetchStatuses)
  }

  @MainActor func testViewRefreshTask() async {
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.mastodon.getAccountStatuses.send = { _ in [] }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshTask))
    await store.receive(\.fetchStatuses)
  }

  @MainActor func testViewRefreshButtonTapped() async {
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.mastodon.getAccountStatuses.send = { _ in [] }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshButtonTapped))
    await store.receive(\.fetchStatuses)
  }

  @MainActor func testViewSeeMoreButtonTapped() async {
    let didOpenURL = LockIsolated<[URL]>([])
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.seeMoreButtonTapped))
    expectNoDifference(didOpenURL.value, [
      FeedReducer.mastodonAccountURL
    ])
  }
}
