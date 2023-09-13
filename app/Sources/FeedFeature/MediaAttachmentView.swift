import AppShared
import Kingfisher
import Mastodon
import SwiftUI

struct MediaAttachmentView: View {
  struct State: Equatable {
    init(_ attachemnt: MediaAttachment) {
      type = attachemnt.type
      previewURL = attachemnt.previewUrl.flatMap(URL.init)
      if let ratio = attachemnt.meta.original?.aspect?.doubleValue {
        aspectRatio = ratio
      } else if let ratio = attachemnt.meta.small?.aspect?.doubleValue {
        aspectRatio = ratio
      } else {
        aspectRatio = 16/9
      }
      url = URL(string: attachemnt.url)
    }

    var type: MediaAttachment.MediaAttachmentType
    var previewURL: URL?
    var aspectRatio: CGFloat?
    var url: URL?
  }

  var state: State

  var body: some View {
    switch state.type {
    case .unknown:
      cardView {
        Text("Attachment")
      }

    case .image:
      cardView {
        KFImage(state.previewURL)
          .resizable()
          .placeholder {
            Color.clear
          }
          .scaledToFit()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background {
            KFImage(state.previewURL)
              .resizable()
              .scaledToFill()
              .blur(radius: 10)
              .opacity(0.8)
          }
      }

    case .gifv:
      cardView {
        Text("GIFV")
      }

    case .video:
      cardView {
        ZStack {
          Color.clear.background {
            KFImage(state.previewURL)
              .resizable()
              .placeholder {
                Color.clear
              }
              .scaledToFill()
              .blur(radius: 10)
              .opacity(0.8)
          }

          VideoPreviewView(url: state.url)
            .scaledToFit()
        }
      }

    case .audio:
      cardView {
        Text("Audio")
      }
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
      content()
      overlay()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(iOS)
    .background(.ultraThickMaterial)
#elseif os(macOS)
    .background(.primary.opacity(0.1))
#endif
    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    VStack(spacing: 10) {
      let attachments: [MediaAttachment] = [Status].preview
        .flatMap { [$0, $0.reblog?.value].compactMap { $0 } }
        .flatMap(\.mediaAttachments)

      ForEach(attachments) { attachment in
        MediaAttachmentView(state: .init(attachment))
          .aspectRatio(1, contentMode: .fill)
      }
    }
    .padding()
  }
  .tint(.appTint)
}
