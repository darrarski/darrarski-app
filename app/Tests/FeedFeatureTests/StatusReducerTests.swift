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

  func testViewPreviewCardTappedOnRebloggedStatus() async {
    let status = [Status].preview.first { $0.reblog?.card != nil }!
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
      XCTAssertNoDifference($0, [URL(string: status.reblog!.card!.url)!])
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

  func testViewAttachmentTapped_Invalid() async {
    let status = [Status].preview.first { $0.mediaAttachments.isEmpty }!
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    }

    await store.send(.view(.attachmentTapped(.init(rawValue: "invalid-id"))))
  }

  func testViewAttachmentTapped_Video() async {
    let status = [Status].preview
      .first { $0.reblog?.mediaAttachments.contains { $0.type == .video } == true }!
    let attachment = status.reblog!.mediaAttachments
      .first { $0.type == .video }!
    let attachmentURL = URL(string: attachment.url)!
    let didOpenURL = ActorIsolated<[URL]>([])
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.attachmentTapped(attachment.id)))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [attachmentURL])
    }
  }

  func testViewAttachmentTapped_Image() async {
    let status = [Status].preview
      .first { $0.mediaAttachments.contains { $0.type == .image } }!
    let attachment = status.mediaAttachments
      .first { $0.type == .image }!
    let attachmentURL = URL(string: attachment.url)!
#if os(macOS)
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    }

    await store.send(.view(.attachmentTapped(attachment.id))) {
      $0.quickLookItem = attachmentURL
    }
    await store.send(.quickLookItem(.dismiss)) {
      $0.quickLookItem = nil
    }
#else
    let didOpenURL = ActorIsolated<[URL]>([])
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.attachmentTapped(attachment.id)))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [attachmentURL])
    }
#endif
  }

  func testViewQuickLookItemChanged() async {
    let status = [Status].preview.first!
    let url = URL(string: "https://darrarski.pl/test")!
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    }

    await store.send(.view(.quickLookItemChanged(url))) {
      $0.quickLookItem = url
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

  func testTextRendering() async {
    var status = [Status].preview.first!
    status.content = "html content"
    status.reblog = nil
    let renderedText = AttributedString("redered text")
    let didRender = LockIsolated<[String]>([])
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.statusTextRenderer.render = { text in
        didRender.withValue { $0.append(text) }
        return renderedText
      }
    }

    await store.send(.view(.textTask))
    await store.receive(.renderText)
    XCTAssertNoDifference(didRender.value, [status.content])
    await store.receive(.textRendered(renderedText)) {
      $0.text = renderedText
    }
  }

  func testTextRenderingFailure() async {
    var status = [Status].preview.first!
    status.content = "html content"
    status.reblog = nil
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.statusTextRenderer.render = { _ in
        throw NSError(domain: "test", code: 1337)
      }
    }

    await store.send(.view(.textTask))
    await store.receive(.renderText)
    await store.receive(.textRendered(AttributedString(status.content))) {
      $0.text = AttributedString(status.content)
    }
  }
}
