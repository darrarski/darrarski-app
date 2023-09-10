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

      WithViewStore(store, observe: \.displayStatus.content) { viewStore in
        HTMLTextView(html: viewStore.state)
          .environment(\.openURL, OpenURLAction { url in
            viewStore.send(.view(.linkTapped(url)))
            return .discarded
          })
      }
      .foregroundStyle(.primary)
      .font(.body)
      .multilineTextAlignment(.leading)
      .frame(maxWidth: .infinity, alignment: .leading)

      ForEachStore(store.scope(state: \.attachments, action: \.1)) { store in
        WithViewStore(store, observe: MediaAttachmentView.State.init) { viewStore in
          Button {
            viewStore.send(.view(.attachmentTapped(store.withState(\.id))))
          } label: {
            MediaAttachmentView(state: viewStore.state)
              .containerRelativeFrame(.vertical) { height, _ in height / 2 }
          }
          .buttonStyle(.plain)
        }
      }

      IfLetStore(store.scope(
        state: \.displayStatus.card,
        action: { $0 }
      )) { store in
        WithViewStore(store, observe: PreviewCardView.State.init) { viewStore in
          Button {
            viewStore.send(.view(.previewCardTapped))
          } label: {
            PreviewCardView(state: viewStore.state)
              .containerRelativeFrame(.vertical) { height, _ in height / 2 }
          }
          .buttonStyle(.plain)
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
