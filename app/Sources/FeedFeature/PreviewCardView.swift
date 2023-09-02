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
    .frame(maxWidth: .infinity, alignment: .leading)
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
      Color.clear
#if os(iOS)
        .background(.ultraThickMaterial)
#elseif os(macOS)
        .background(.primary.opacity(0.1))
#endif
        .background(.ultraThickMaterial)
        .aspectRatio(16/9, contentMode: .fit)
        .overlay {
          AsyncImage(url: imageURL) { image in
            image
              .resizable()
              .scaledToFill()

          } placeholder: {
            Color.clear
          }
        }
        .clipped()
    }
  }

  @MainActor
  var details: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(state.title)
        .foregroundStyle(.primary)
        .font(.headline)
        .fixedSize(horizontal: false, vertical: true)

      Text(state.description)
        .foregroundStyle(.primary)
        .font(.subheadline)
        .fixedSize(horizontal: false, vertical: true)

      if let footer = state.footer {
        Text(footer)
          .foregroundStyle(.link)
          .font(.subheadline)
          .lineLimit(1)
      }
    }
    .padding()
  }
}

#Preview {
  ScrollView {
    PreviewCardView(state: PreviewCardView.State(
      [Status].preview.first!.reblog!.value.card!
    ))
    .padding()
  }
}
