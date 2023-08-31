import ComposableArchitecture
import SwiftUI

public struct ContactView: View {
  public init(store: StoreOf<ContactReducer>) {
    self.store = store
  }

  let store: StoreOf<ContactReducer>

  public var body: some View {
    ScrollView {
      VStack {
        header
        buttons
      }
      .frame(maxWidth: 500)
      .frame(maxWidth: .infinity)
      .padding()
    }
    .task {
      await store.send(.view(.task)).finish()
    }
    .refreshTask {
      await store.send(.view(.refreshTask)).finish()
    }
    .navigationTitle("Darrarski")
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

  @MainActor
  var header: some View {
    BackgroundGeometryReader(geometry: \.size.width) { width in
      let avatarSize = width.map { $0 / 3 }

      HStack(alignment: .top) {
        WithViewStore(store, observe: \.contact?.avatarURL) { viewStore in
          AvatarView(url: viewStore.state)
        }
        .frame(width: avatarSize, height: avatarSize)
        .padding(.bottom)

        details
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding([.leading, .vertical])
      }
    }
  }

  @MainActor
  var details: some View {
    VStack(alignment: .leading) {
      WithViewStore(store, observe: \.contact?.name) { viewStore in
        let value = viewStore.state
        let placeholder = "Dariusz Rybicki"
        let text = value ?? placeholder

        Text(text)
          .font(.title)
          .redacted(reason: value == nil ? .placeholder : [])
          .animation(.bouncy, value: text)
      }

      WithViewStore(store, observe: \.contact?.description) { viewStore in
        let value = viewStore.state
        let placeholder = "Redacted Placeholder\nLorem ipsum\nPariatur ex aliqua ut"
        let text = value ?? placeholder

        Text(text)
          .font(.headline)
          .redacted(reason: value == nil ? .placeholder : [])
          .animation(.bouncy, value: text)
      }
    }
  }

  @MainActor
  var buttons: some View {
    // TODO:
    VStack {
      Button {} label: {
        Text("Button")
          .frame(maxWidth: .infinity)
      }
    }
    .controlSize(.extraLarge)
    .buttonStyle(.borderedProminent)
  }
}

#Preview {
  NavigationStack {
    ContactView(store: Store(initialState: ContactReducer.State()) {
      ContactReducer()
    })
  }
}
