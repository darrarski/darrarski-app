import AppShared
import ComposableArchitecture
import Mastodon
import QuickLook
import SwiftUI

@ViewAction(for: StatusReducer.self)
public struct StatusView: View {
  public init(store: StoreOf<StatusReducer>) {
    self.store = store
  }

  public let store: StoreOf<StatusReducer>

  public var body: some View {
    VStack {
      header
      text
      gallery
    }
    .background {
      quickLookSheet
    }
  }

  @MainActor
  var header: some View {
    Button {
      send(.headerTapped)
    } label: {
      StatusHeaderView(store.displayStatus)
    }
    .buttonStyle(.plain)
  }

  @MainActor
  @ViewBuilder
  var text: some View {
    let text = store.text ?? AttributedString.statusTextPlaceholder
    let isPlaceholder = store.text == nil
    
    Text(text)
      .redacted(reason: isPlaceholder ? .placeholder : [])
      .disabled(isPlaceholder)
      .onChange(of: isPlaceholder, initial: true) { _, isPlaceholder in
        if isPlaceholder { send(.textTask) }
      }
      .environment(\.openURL, OpenURLAction { url in
        send(.linkTapped(url))
        return .discarded
      })
      .animation(.bouncy, value: isPlaceholder)
      .foregroundStyle(.primary)
      .font(.body)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  @MainActor
  @ViewBuilder
  var gallery: some View {
    let hasAttachments = !store.attachments.isEmpty
    let hasPreviewCard = store.displayStatus.card != nil
    let show = hasAttachments || hasPreviewCard

    if show {
      ScrollView(.horizontal) {
        HStack(spacing: 0) {
          Spacer()
            .containerRelativeFrame(.horizontal) { width, _ in width * 0.1 }

          HStack(spacing: 16) {
            Group {
              previewCard
              attachments
            }
            .buttonStyle(.plain)
            .aspectRatio(1, contentMode: .fit)
            .containerRelativeFrame(.horizontal) { width, _ in min(width * 0.8, 400) }
          }
          .scrollTargetLayout()

          Spacer()
            .containerRelativeFrame(.horizontal) { width, _ in width * 0.1 }
        }
      }
      .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
      .scrollIndicators(.hidden)
      .scrollClipDisabled()
    }
  }

  @MainActor
  @ViewBuilder
  var previewCard: some View {
    if let card = store.displayStatus.card {
      Button {
        send(.previewCardTapped)
      } label: {
        PreviewCardView(card)
      }
    }
  }

  @MainActor
  var attachments: some View {
    ForEach(store.attachments) { attachment in
      Button {
        send(.attachmentTapped(attachment.id))
      } label: {
        MediaAttachmentView(attachment)
      }
    }
  }

  @MainActor
  var quickLookSheet: some View {
    Color.clear.quickLookPreview(Binding(
      get: { store.quickLookItem },
      set: { url, transaction in
        guard store.quickLookItem != url else { return }
        send(.quickLookItemChanged(url), transaction: transaction)
      }
    ))
  }
}

private extension AttributedString {
  static let statusTextPlaceholder = AttributedString("""
    Proident sit adipisicing ex nulla. Ea id proident laboris occaecat excepteur. 
    Consectetur deserunt excepteur cillum.
    Esse laborum laborum qui ut eu non amet consectetur consectetur elit dolor consequat pariatur.
    """)
}

#Preview {
  ScrollView {
    StatusView(store: Store(initialState: StatusReducer.State(
      status: [Status].preview[0]
    )) {
      StatusReducer()
    })
    .padding()
  }
  .tint(.appTint)
}
