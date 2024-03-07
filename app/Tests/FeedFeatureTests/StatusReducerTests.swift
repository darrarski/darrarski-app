import ComposableArchitecture
import Mastodon
import XCTest
@testable import FeedFeature

final class StatusReducerTests: XCTestCase {
  @MainActor func testViewPreviewCardTapped() async {
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

  @MainActor func testViewPreviewCardTappedOnRebloggedStatus() async {
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

  @MainActor func testViewLinkTapped() async {
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

  @MainActor func testViewAttachmentTapped_Invalid() async {
    let status = [Status].preview.first { $0.mediaAttachments.isEmpty }!
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    }

    await store.send(.view(.attachmentTapped(.init(rawValue: "invalid-id"))))
  }

  @MainActor func testViewAttachmentTapped_Video() async {
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

  @MainActor func testViewAttachmentTapped_Image() async {
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

  @MainActor func testViewQuickLookItemChanged() async {
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

  @MainActor func testViewHeaderTapped() async {
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

  @MainActor func testViewReblogHeaderTapped() async {
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

  @MainActor func testStateDisplayStatus() {
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

  @MainActor func testStateAttachments() {
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

  @MainActor func testTextRendering() async {
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
    await store.receive(\.renderText)
    XCTAssertNoDifference(didRender.value, [status.content])
    await store.receive(\.textRendered.success) {
      $0.text = renderedText
    }

    await store.send(.view(.textTask))
  }

  @MainActor func testTextRenderingFailure() async {
    struct Failure: Error, Equatable {}
    let failure = Failure()
    var status = [Status].preview.first!
    status.content = "html content"
    status.reblog = nil
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.statusTextRenderer.render = { _ in throw failure }
    }

    await store.send(.view(.textTask))
    await store.receive(\.renderText)
    await store.receive(\.textRendered.failure) {
      $0.text = AttributedString(status.content)
    }
  }
}
