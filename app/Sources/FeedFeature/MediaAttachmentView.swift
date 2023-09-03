import AppShared
import Mastodon
import SwiftUI

struct MediaAttachmentView: View {
  struct State: Equatable {
    init(_ attachemnt: MediaAttachment) {
      type = attachemnt.type
      previewURL = attachemnt.previewUrl.flatMap(URL.init)
      if let ratio = attachemnt.meta.original?.aspect?.double {
        aspectRatio = ratio
      } else if let ratio = attachemnt.meta.small?.aspect?.double {
        aspectRatio = ratio
      } else {
        aspectRatio = 16/9
      }
    }

    var type: MediaAttachment.MediaAttachmentType
    var previewURL: URL?
    var aspectRatio: CGFloat?
  }

  var state: State

  var body: some View {
    switch state.type {
    case .unknown:
      EmptyView()

    case .image:
      cardView {
        AsyncImage(url: state.previewURL) { image in
          image
            .resizable()
            .scaledToFill()

        } placeholder: {
          Color.clear
        }
      }

    case .gifv:
      EmptyView()

    case .video:
      EmptyView()

    case .audio:
      EmptyView()
    }
  }

  func cardView<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    cardView(content: content, overlay: EmptyView.init)
  }

  func cardView<Content: View, Overlay: View>(
    @ViewBuilder content: () -> Content,
    @ViewBuilder overlay: () -> Overlay
  ) -> some View {
    ZStack {
      Color.clear
#if os(iOS)
        .background(.ultraThickMaterial)
#elseif os(macOS)
        .background(.primary.opacity(0.1))
#endif
        .background(.ultraThickMaterial)
        .aspectRatio(state.aspectRatio, contentMode: .fit)
        .overlay {
          content()
        }
        .clipped()

      overlay()
    }
    .frame(maxWidth: .infinity)
#if os(iOS)
    .background(.thickMaterial)
#elseif os(macOS)
    .background(.background)
#endif
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .stroke(.primary.opacity(0.1), lineWidth: 1)
    }
  }
}

#Preview {
  ScrollView {
    VStack {
      let attachments: [MediaAttachment] = [Status].preview
        .flatMap { [$0, $0.reblog?.value].compactMap { $0 } }
        .flatMap(\.mediaAttachments)

      ForEach(attachments) { attachment in
        MediaAttachmentView(state: .init(attachment))
      }
    }
    .padding()
  }
  .tint(.appTint)
}
