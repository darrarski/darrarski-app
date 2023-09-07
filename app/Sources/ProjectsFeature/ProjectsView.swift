import AppShared
import ComposableArchitecture
import SwiftUI

public struct ProjectsView: View {
  public init(store: StoreOf<ProjectsReducer>) {
    self.store = store
  }

  let store: StoreOf<ProjectsReducer>

  public var body: some View {
    ScrollView {
      LazyVStack {
        ForEachStore(store.scope(state: \.groups, action: \.1)) { store in
          WithViewStore(store, observe: \.date) { viewStore in
            Text(viewStore.state.formatted(Date.FormatStyle().year(.extended())))
              .font(.title)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          LazyVStack {
            ForEachStore(store.scope(state: \.projects, action: \.1)) { store in
              WithViewStore(store, observe: \.name) { viewStore in
                Text("\(viewStore.state)")
                  .font(.title2)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
            }
          }
          .padding(.bottom)
          .padding(.bottom)
        }
      }
      .frame(maxWidth: 500, alignment: .leading)
      .frame(maxWidth: .infinity)
      .padding()
    }
    .task {
      await store.send(.view(.task)).finish()
    }
    .refreshTask {
      await store.send(.view(.refreshTask)).finish()
    }
    .navigationTitle("Projects")
#if os(macOS)
    .toolbar {
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
    }
#endif
  }
}

#Preview {
  NavigationStack {
    ProjectsView(store: Store(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    })
  }
  .tint(.appTint)
}
