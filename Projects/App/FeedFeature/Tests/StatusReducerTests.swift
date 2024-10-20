import ComposableArchitecture
import Mastodon
import XCTest
@testable import FeedFeature

final class StatusReducerTests: XCTestCase {
  @MainActor func testViewPreviewCardTapped() async {
    let status = [Status].preview.first { $0.card != nil }!
    let card = status.card!
    let cardURL = URL(string: card.url)!
    let didOpenURL = LockIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(
      status: status
    )) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.previewCardTapped))
    expectNoDifference(didOpenURL.value, [cardURL])
  }

  @MainActor func testViewPreviewCardTappedOnRebloggedStatus() async {
    let status = [Status].preview.first { $0.reblog?.card != nil }!
    let didOpenURL = LockIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(
      status: status
    )) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.previewCardTapped))
    expectNoDifference(didOpenURL.value, [URL(string: status.reblog!.card!.url)!])
  }

  @MainActor func testViewLinkTapped() async {
    let url = URL(string: "https://darrarski.pl")!
    let didOpenURL = LockIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(
      status: [Status].preview.first!
    )) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.linkTapped(url)))
    expectNoDifference(didOpenURL.value, [url])
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
    let didOpenURL = LockIsolated<[URL]>([])
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.attachmentTapped(attachment.id)))
    expectNoDifference(didOpenURL.value, [attachmentURL])
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
    let didOpenURL = LockIsolated<[URL]>([])
    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.attachmentTapped(attachment.id)))
    expectNoDifference(didOpenURL.value, [attachmentURL])
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
    let didOpenURL = LockIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.headerTapped))
    expectNoDifference(didOpenURL.value, [statusURL])
  }

  @MainActor func testViewReblogHeaderTapped() async {
    let status = [Status].preview.first { $0.reblog != nil }!
    let statusURL = URL(string: status.reblog!.url!)!
    let didOpenURL = LockIsolated<[URL]>([])

    let store = TestStore(initialState: StatusReducer.State(status: status)) {
      StatusReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.headerTapped))
    expectNoDifference(didOpenURL.value, [statusURL])
  }

  @MainActor func testStateDisplayStatus() {
    let statusWithReblog = [Status].preview.first { $0.reblog != nil }!
    let statusWithoutReblog = [Status].preview.first { $0.reblog == nil }!

    expectNoDifference(
      StatusReducer.State(status: statusWithReblog).displayStatus,
      statusWithReblog.reblog!.value
    )
    expectNoDifference(
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
    
    expectNoDifference(StatusReducer.State(status: status).attachments, [
      allAttachments[0],
      allAttachments[1],
      allAttachments[2],
      allAttachments[3],
    ])
  }
}
