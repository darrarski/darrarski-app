import ComposableArchitecture
import Mastodon
import XCTest
@testable import FeedFeature

@MainActor
final class FeedReducerTests: XCTestCase {
  func testFetchStatuses() async {
    let clock = TestClock()
    let didFetchWithQuery = ActorIsolated<[Mastodon.GetAccountStatuses.Query]>([])
    let statuses = [Status].preview
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = clock
      $0.mastodon.getAccountStatuses.run = { query in
        await didFetchWithQuery.withValue { $0.append(query) }
        return statuses
      }
    }

    await store.send(.fetchStatuses) {
      $0.isLoading = true
    }
    await clock.advance(by: .seconds(0.5))
    await didFetchWithQuery.withValue {
      XCTAssertNoDifference($0, [.init(
        accountId: FeedReducer.mastodonAccountId,
        limit: 40,
        excludeReplies: true
      )])
    }
    await store.receive(\.fetchStatusesResult.success) {
      $0.isLoading = false
      $0.statuses = .init(
        uniqueElements: statuses.map { StatusReducer.State(status: $0) }
      )
    }
  }

  func testFetchStatusesFailure() async {
    let error = NSError(domain: "test", code: 1234)
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.mastodon.getAccountStatuses.run = { _ in throw error }
    }

    await store.send(.fetchStatuses) {
      $0.isLoading = true
    }
    await store.receive(\.fetchStatusesResult.failure) {
      $0.isLoading = false
    }
  }

  func testViewTask() async {
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.mastodon.getAccountStatuses.run = { _ in [] }
    }
    store.exhaustivity = .off

    await store.send(.view(.task))
    await store.receive(\.fetchStatuses)
  }

  func testViewRefreshTask() async {
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.mastodon.getAccountStatuses.run = { _ in [] }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshTask))
    await store.receive(\.fetchStatuses)
  }

  func testViewRefreshButtonTapped() async {
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.mastodon.getAccountStatuses.run = { _ in [] }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshButtonTapped))
    await store.receive(\.fetchStatuses)
  }

  func testViewSeeMoreButtonTapped() async {
    let didOpenURL = ActorIsolated<[URL]>([])
    let store = TestStore(initialState: FeedReducer.State()) {
      FeedReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.seeMoreButtonTapped))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [
        FeedReducer.mastodonAccountURL
      ])
    }
  }
}
