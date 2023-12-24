import AppShared
import Kingfisher
import Mastodon
import SwiftUI

struct MediaAttachmentView: View {
  init(_ attachment: MediaAttachment) {
    type = attachment.type
    previewURL = attachment.previewUrl.flatMap(URL.init)
    if let ratio = attachment.meta.original?.aspect?.doubleValue {
      aspectRatio = ratio
    } else if let ratio = attachment.meta.small?.aspect?.doubleValue {
      aspectRatio = ratio
    } else {
      aspectRatio = 16/9
    }
    url = URL(string: attachment.url)
  }

  var type: MediaAttachment.MediaAttachmentType
  var previewURL: URL?
  var aspectRatio: CGFloat?
  var url: URL?

  var body: some View {
    switch type {
    case .unknown:
      cardView {
        Text("Attachment")
      }

    case .image:
      cardView {
        KFImage(previewURL)
          .resizable()
          .placeholder {
            Color.clear
          }
          .scaledToFit()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background {
            KFImage(previewURL)
              .resizable()
              .scaledToFill()
              .blur(radius: 10)
              .opacity(0.8)
              .allowsHitTesting(false)
          }
      }

    case .gifv, .video:
      cardView {
        ZStack {
          Color.clear.background {
            KFImage(previewURL)
              .resizable()
              .placeholder {
                Color.clear
              }
              .scaledToFill()
              .blur(radius: 10)
              .opacity(0.8)
              .allowsHitTesting(false)
          }

          VideoPreviewView(url: url)
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
        MediaAttachmentView(attachment)
          .aspectRatio(1, contentMode: .fill)
      }
    }
    .padding()
  }
  .tint(.appTint)
}
