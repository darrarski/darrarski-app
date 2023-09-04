import ComposableArchitecture
import Foundation
import Mastodon

public struct StatusReducer: Reducer, Sendable {
  public struct State: Equatable, Sendable, Identifiable {
    public init(
      status: Status,
      quickLookItem: URL? = nil
    ) {
      self.status = status
      self.quickLookItem = quickLookItem
    }

    public var id: Status.ID { status.id }
    var status: Status
    @PresentationState var quickLookItem: URL?

    var displayStatus: Status {
      status.reblog?.value ?? status
    }

    var attachments: IdentifiedArrayOf<MediaAttachment> {
      var attachments = IdentifiedArrayOf<MediaAttachment>()
      attachments.append(contentsOf: status.mediaAttachments)
      for attachment in (status.reblog?.mediaAttachments ?? []) {
        if attachments[id: attachment.id] == nil {
          attachments.append(attachment)
        }
      }
      return attachments
    }
  }

  public enum Action: Equatable, Sendable {
    case quickLookItem(PresentationAction<Never>)
    case view(View)

    public enum View: Equatable, Sendable {
      case attachmentTapped(MediaAttachment.ID)
      case headerTapped
      case linkTapped(URL)
      case previewCardTapped
      case quickLookItemChanged(URL)
    }
  }

  public init() {}

  @Dependency(\.openURL) var openURL

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .quickLookItem(_):
        return .none

      case .view(.attachmentTapped(let id)):
        if let url = state.attachments[id: id].map(\.url).flatMap(URL.init) {
          state.quickLookItem = url
        }
        return .none

      case .view(.headerTapped):
        return .run { [state] _ in
          if let url = state.displayStatus.url.flatMap(URL.init) {
            await openURL(url)
          }
        }

      case .view(.linkTapped(let url)):
        return .run { _ in await openURL(url) }

      case .view(.previewCardTapped):
        return .run { [state] _ in
          if let url = (state.status.card?.url).flatMap(URL.init) {
            await openURL(url)
          }
        }

      case .view(.quickLookItemChanged(let url)):
        state.quickLookItem = url
        return .none
      }
    }
    .ifLet(\.$quickLookItem, action: /Action.quickLookItem) {
      EmptyReducer()
    }
  }
}
