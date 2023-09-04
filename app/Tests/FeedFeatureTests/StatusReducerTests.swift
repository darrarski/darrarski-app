import ComposableArchitecture
import Mastodon
import XCTest
@testable import FeedFeature

@MainActor
final class StatusReducerTests: XCTestCase {
  func testViewPreviewCardTapped() async {
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

    await store.send(.view(.previewCardTapped))
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

  func testViewAttachmentTapped() async {
    let status = [Status].preview.first { !$0.mediaAttachments.isEmpty }!
    let attachment = status.mediaAttachments.first!
    let attachmentURL = URL(string: attachment.url)!

    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    }

    await store.send(.view(.attachmentTapped(attachment.id))) {
      $0.quickLookItem = attachmentURL
    }
    let newURL = URL(string: "https://darrarski.pl/test")!
    await store.send(.view(.quickLookItemChanged(newURL))) {
      $0.quickLookItem = newURL
    }
    await store.send(.quickLookItem(.dismiss)) {
      $0.quickLookItem = nil
    }
  }

  func testViewHeaderTapped() async {
    let status = [Status].preview.first { $0.reblog == nil }!
    let statusURL = URL(string: status.url!)!
    let didOpenURL = ActorIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.headerTapped))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [statusURL])
    }
  }

  func testViewReblogHeaderTapped() async {
    let status = [Status].preview.first { $0.reblog != nil }!
    let statusURL = URL(string: status.reblog!.url!)!
    let didOpenURL = ActorIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.headerTapped))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [statusURL])
    }
  }

  func testStateDisplayStatus() {
    let statusWithReblog = [Status].preview.first { $0.reblog != nil }!
    let statusWithoutReblog = [Status].preview.first { $0.reblog == nil }!

    XCTAssertNoDifference(
      StatusReducer.State(status: statusWithReblog).displayStatus,
      statusWithReblog.reblog!.value
    )
    XCTAssertNoDifference(
      StatusReducer.State(status: statusWithoutReblog).displayStatus,
      statusWithoutReblog
    )
  }

  func testStateAttachments() {
    let allStatuses = [Status].preview
    let allStatusAttachments = allStatuses.flatMap(\.mediaAttachments)
    let allReblogs = allStatuses.compactMap(\.reblog?.value)
    let allRebloggedAttachments = allReblogs.flatMap(\.mediaAttachments)
    let allAttachments = (allStatusAttachments + allRebloggedAttachments)
    var status = [Status].preview.first { $0.reblog != nil }!
    status.mediaAttachments = Array(allAttachments[0...2])
    status.reblog!.mediaAttachments = Array(allAttachments[1...3])
    
    XCTAssertNoDifference(StatusReducer.State(status: status).attachments, [
      allAttachments[0],
      allAttachments[1],
      allAttachments[2],
      allAttachments[3],
    ])
  }
}
