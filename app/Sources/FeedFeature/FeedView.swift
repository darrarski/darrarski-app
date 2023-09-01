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
      LazyVStack {
        ForEachStore(
          store.scope(
            state: \.statuses,
            action: FeedReducer.Action.status
          ),
          content: StatusView.init(store:)
        )
      }
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
