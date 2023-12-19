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

  public var body: some View {
    let animationValue: OrderedSet<StatusReducer.State.ID> = store.statuses.ids
    let showPlaceholder: Bool = store.statuses.isEmpty && store.isLoading
    let showMoreButton: Bool = !store.statuses.isEmpty

    ScrollView {
      LazyVStack(spacing: 32) {
        if showPlaceholder {
          placeholderView
        } else {
          ForEach(store.scope(state: \.statuses, action: \.status)) { statusStore in
            StatusView(store: statusStore)
          }
          .transition(
            .scale(scale: placeholderScale, anchor: .center)
            .combined(with: .opacity)
          )

          if showMoreButton {
            Button {
              store.send(.view(.seeMoreButtonTapped))
            } label: {
              Text("See more on Mastodon")
                .padding(.horizontal)
            }
            .controlSize(.extraLarge)
            .buttonStyle(.borderedProminent)
            .transition(.opacity)
          }
        }
      }
      .animation(.bouncy, value: animationValue)
      .frame(maxWidth: .infinity)
      .padding(16)
    }
    .navigationTitle("Feed")
    .toolbar {
#if os(macOS)
      ToolbarItem(placement: .primaryAction) {
        Button {
          store.send(.view(.refreshButtonTapped))
        } label: {
          Text("Refresh")
        }
        .disabled(store.isLoading)
      }
#elseif os(iOS)
      ToolbarItem {
        if !isRefreshing, store.isLoading {
          ProgressView()
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
    let statuses: [Status] = .preview.shuffled().suffix(3)
      .enumerated()
      .map(makeUpdate { $0.element.id = .init(rawValue: "preview\($0.offset)") })
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
  .tint(.appTint)
}
