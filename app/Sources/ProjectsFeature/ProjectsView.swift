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
      WithViewStore(store, observe: \.projects) { viewStore in
        var projects = ""
        let _ = customDump(viewStore.state, to: &projects)
        Text(projects)
      }
      .multilineTextAlignment(.leading)
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
