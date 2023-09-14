import AppShared
import Kingfisher
import Mastodon
import SwiftUI

struct PreviewCardView: View {
  struct State: Equatable {
    init(_ card: PreviewCard) {
      imageURL = card.image.flatMap(URL.init)
      title = card.title
      description = card.description
      if !card.providerName.isEmpty {
        footer = card.providerName
      } else {
        footer = URL(string: card.url)?.host()
      }
    }

    var imageURL: URL?
    var title: String
    var description: String
    var footer: String?
  }

  enum Layout: Equatable {
    case horizontal
    case vertical
  }

  var state: State

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      image
      details
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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

  @MainActor
  @ViewBuilder
  var image: some View {
    if let imageURL = state.imageURL {
      KFImage(imageURL)
        .resizable()
        .placeholder {
          Color.clear
        }
        .scaledToFit()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
          KFImage(imageURL)
            .resizable()
            .placeholder {
              Color.clear
            }
            .scaledToFill()
            .blur(radius: 10)
            .opacity(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
#if os(iOS)
        .background(.ultraThickMaterial)
#elseif os(macOS)
        .background(.primary.opacity(0.1))
#endif
    }
  }

  @MainActor
  var details: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(state.title)
        .foregroundStyle(.primary)
        .font(.headline)

      Text(state.description)
        .foregroundStyle(.primary)
        .font(.subheadline)

      if state.imageURL == nil {
        Spacer(minLength: 0)
      }

      if let footer = state.footer {
        Text(footer)
          .foregroundStyle(.tint)
          .font(.subheadline)
          .lineLimit(1)
      }
    }
    .padding()
  }
}

#Preview {
  PreviewCardView(state: PreviewCardView.State(
    [Status].preview.first!.reblog!.card!
  ))
  .padding()
  .tint(.appTint)
}
