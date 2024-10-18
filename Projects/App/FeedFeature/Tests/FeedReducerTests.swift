import ComposableArchitecture
import Mastodon
import XCTest
@testable import FeedFeature

final class FeedReducerTests: XCTestCase {
  @MainActor func testFetchStatuses() async {
    let clock = TestClock()
    let didFetch = LockIsolated<[Mastodon.GetAccountStatuses.Request]>([])
    let statuses = [Status].preview
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = clock
      $0.mastodon.getAccountStatuses.send = { request in
        didFetch.withValue { $0.append(request) }
        return statuses
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
        uniqueElements: statuses.map { StatusReducer.State(status: $0) }
      )
    }
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
