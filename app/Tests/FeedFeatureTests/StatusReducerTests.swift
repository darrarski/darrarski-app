import ComposableArchitecture
import Mastodon
import XCTest
@testable import FeedFeature

@MainActor
final class StatusReducerTests: XCTestCase {
  func testViewCardTapped() async {
    let status = [Status].preview.first { $0.card != nil }!
    let card = status.card!
    let cardURL = URL(string: card.url)!
    let didOpenURL = ActorIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(
      status: status
    )) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.cardTapped(card)))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [cardURL])
    }
  }

  func testViewLinkTapped() async {
    let url = URL(string: "https://darrarski.pl")!
    let didOpenURL = ActorIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(
      status: [Status].preview.first!
    )) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.linkTapped(url)))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [url])
    }
  }
}
