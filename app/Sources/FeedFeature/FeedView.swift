import AppShared
import ComposableArchitecture
import Mastodon
import OrderedCollections
import SwiftUI

public struct FeedView: View {
  public init(store: StoreOf<FeedReducer>) {
    self.store = store
  }

  let store: StoreOf<FeedReducer>
  @State var isRefreshing = false
  var placeholderScale: CGFloat = 0.95

  struct ViewState: Equatable {
    init(_ state: FeedReducer.State) {
      animationValue = state.statuses.ids
      showPlaceholder = state.statuses.isEmpty && state.isLoading
    }

    var animationValue: OrderedSet<StatusReducer.State.ID>
    var showPlaceholder: Bool
  }

  public var body: some View {
    ScrollView {
      WithViewStore(store, observe: ViewState.init) { viewStore in
        LazyVStack(spacing: 32) {
          if viewStore.showPlaceholder {
            placeholderView
          } else {
            ForEachStore(
              store.scope(
                state: \.statuses,
                action: FeedReducer.Action.status
              ),
              content: StatusView.init(store:)
            )
            .transition(
              .scale(scale: placeholderScale, anchor: .center)
              .combined(with: .opacity)
            )
          }
        }
        .animation(.bouncy, value: viewStore.animationValue)
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

  @MainActor
  @ViewBuilder
  var placeholderView: some View {
    let statuses: [Status] = .preview.shuffled()[0..<3]
      .enumerated()
      .map(makeUpdate { $0.element.id = "preview\($0.offset)" })
      .map(\.element)

    ForEach(statuses) { status in
      StatusView(store: Store(
        initialState: StatusReducer.State(status: status),
        reducer: EmptyReducer.init
      ))
      .redacted(reason: .placeholder)
      .disabled(true)
      .opacity(0.5)
      .scaleEffect(x: placeholderScale, y: placeholderScale, anchor: .center)
      .transition(.opacity)
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
