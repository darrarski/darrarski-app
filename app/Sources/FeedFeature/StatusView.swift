import AppShared
import ComposableArchitecture
import Mastodon
import QuickLook
import SwiftUI

public struct StatusView: View {
  public init(store: StoreOf<StatusReducer>) {
    self.store = store
  }

  let store: StoreOf<StatusReducer>

  public var body: some View {
    VStack {
      WithViewStore(store) {
        StatusHeaderView.State($0.displayStatus)
      } content: { viewStore in
        Button {
          viewStore.send(.view(.headerTapped))
        } label: {
          StatusHeaderView(state: viewStore.state)
        }
        .buttonStyle(.plain)
      }

      WithViewStore(store, observe: \.text) { viewStore in
        let text = viewStore.state ?? AttributedString.statusTextPlaceholder
        let isPlaceholder = viewStore.state == nil
        Text(text)
          .redacted(reason: isPlaceholder ? .placeholder : [])
          .disabled(isPlaceholder)
          .onChange(of: viewStore.state == nil, initial: true) { _, isNil in
            if isNil { viewStore.send(.view(.textTask)) }
          }
          .environment(\.openURL, OpenURLAction { url in
            viewStore.send(.view(.linkTapped(url)))
            return .discarded
          })
          .animation(.bouncy, value: isPlaceholder)
      }
      .foregroundStyle(.primary)
      .font(.body)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)

      WithViewStore(store) { state -> Bool in
        let hasAttachments = !state.attachments.isEmpty
        let hasPreviewCard = state.displayStatus.card != nil
        return hasAttachments || hasPreviewCard
      } content: { viewStore in
        if viewStore.state {
          ScrollView(.horizontal) {
            HStack(spacing: 16) {
              Group {
                IfLetStore(store.scope(
                  state: \.displayStatus.card,
                  action: { $0 }
                )) { store in
                  WithViewStore(store, observe: PreviewCardView.State.init) { viewStore in
                    Button {
                      viewStore.send(.view(.previewCardTapped))
                    } label: {
                      PreviewCardView(state: viewStore.state)
                    }
                  }
                }

                ForEachStore(store.scope(state: \.attachments, action: \.1)) { store in
                  WithViewStore(store, observe: MediaAttachmentView.State.init) { viewStore in
                    Button {
                      viewStore.send(.view(.attachmentTapped(store.withState(\.id))))
                    } label: {
                      MediaAttachmentView(state: viewStore.state)
                    }
                  }
                }
              }
              .buttonStyle(.plain)
              .containerRelativeFrame(.horizontal) { width, _ in width * 0.8 }
            }
            .scrollTargetLayout()
          }
          .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
          .scrollIndicators(.hidden)
          .scrollClipDisabled()
          .containerRelativeFrame(.vertical) { height, _ in height / 2 }
        }
      }
    }
    .background {
      WithViewStore(store, observe: \.quickLookItem) { viewStore in
        Color.clear.quickLookPreview(Binding(
          get: { viewStore.state },
          set: { url, transaction in
            if let url {
              viewStore.send(.view(.quickLookItemChanged(url)), transaction: transaction)
            } else {
              viewStore.send(.quickLookItem(.dismiss), transaction: transaction)
            }
          }
        ))
      }
    }
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
