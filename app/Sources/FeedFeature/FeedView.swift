import AppShared
import ComposableArchitecture
import SwiftUI

public struct FeedView: View {
  public init(store: StoreOf<FeedReducer>) {
    self.store = store
  }

  let store: StoreOf<FeedReducer>
  @State var isRefreshing = false

  public var body: some View {
    ScrollView {
      WithViewStore(store, observe: \.statuses.ids) { viewStore in
        LazyVStack(spacing: 16) {
          ForEachStore(
            store.scope(
              state: \.statuses,
              action: FeedReducer.Action.status
            ),
            content: StatusView.init(store:)
          )
          .transition(.asymmetric(
            insertion: .scale(scale: 0.95, anchor: .center).combined(with: .opacity),
            removal: .opacity
          ))
        }
        .animation(.bouncy, value: viewStore.state)
      }
      .frame(maxWidth: 600)
      .frame(maxWidth: .infinity)
      .padding(16)
    }
    .navigationTitle("Feed")
    .toolbar {
#if os(macOS)
      ToolbarItem(placement: .primaryAction) {
        WithViewStore(store, observe: \.isLoading) { viewStore in
          let isLoading = viewStore.state

          Button {
            store.send(.view(.refreshButtonTapped))
          } label: {
            Text("Refresh")
          }
          .disabled(isLoading)
        }
      }
#elseif os(iOS)
      ToolbarItem {
        if !isRefreshing {
          WithViewStore(store, observe: \.isLoading) { viewStore in
            if viewStore.state {
              ProgressView()
            }
          }
        }
      }
#endif
    }
    .task {
      await store.send(.view(.task)).finish()
    }
    .refreshTask {
      isRefreshing = true
      defer { isRefreshing = false }
      await store.send(.view(.refreshTask)).finish()
    }
  }
}

#Preview {
  NavigationStack {
    FeedView(store: Store(initialState: FeedReducer.State()) {
      FeedReducer()
    })
  }
}
