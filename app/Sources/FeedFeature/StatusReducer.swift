import ComposableArchitecture
import Foundation
import Mastodon

public struct StatusReducer: Reducer, Sendable {
  public struct State: Equatable, Sendable, Identifiable {
    public init(
      status: Status
    ) {
      self.status = status
    }

    public var id: Status.ID { status.id }
    var status: Status

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
    case view(View)

    public enum View: Equatable, Sendable {
      case attachmentTapped(MediaAttachment.ID)
      case linkTapped(URL)
      case previewCardTapped
    }
  }

  public init() {}

  @Dependency(\.openURL) var openURL

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .view(.attachmentTapped(let id)):
        return .run { [state] _ in
          if let url = state.attachments[id: id].map(\.url).flatMap(URL.init) {
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
      }
    }
  }
}
