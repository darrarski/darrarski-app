import ComposableArchitecture
import Kingfisher
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
        avatar
          .frame(width: avatarSize, height: avatarSize)
          .padding(.bottom)

        details
          .frame(maxWidth: .infinity, alignment: .leading)
          .padding([.leading, .vertical])
      }
    }
  }

  @MainActor
  var avatar: some View {
    WithViewStore(store, observe: \.gravatar?.entry.first?.thumbnailUrl) { viewStore in
      let imageURL = viewStore.state?.appending(queryItems: [
        .init(name: "s", value: "450")
      ])

      KFImage(imageURL)
        .resizable()
        .placeholder {
          Image(systemName: "person")
            .resizable()
            .bold()
            .scaleEffect(CGSize(width: 0.5, height: 0.5), anchor: .center)
            .padding(-10)
        }
    }
    .aspectRatio(contentMode: .fit)
    .background(Color.secondary)
    .clipShape(Circle())
    .shadow(color: .accentColor, radius: 10, x: 0, y: 0)
  }

  @MainActor
  var details: some View {
    VStack(alignment: .leading) {
      WithViewStore(store, observe: \.gravatar?.entry.first?.name.formatted) { viewStore in
        let value = viewStore.state
        let placeholder = "Dariusz Rybicki"
        let text = value ?? placeholder

        Text(text)
          .font(.title)
          .redacted(reason: value == nil ? .placeholder : [])
          .animation(.easeInOut, value: text)
      }

      WithViewStore(store, observe: \.gravatar?.entry.first?.aboutMe) { viewStore in
        let value = viewStore.state
        let placeholder = "Redacted Placeholder\nLorem ipsum\nPariatur ex aliqua ut"
        let text = value ?? placeholder

        Text(text)
          .font(.headline)
          .redacted(reason: value == nil ? .placeholder : [])
          .animation(.easeInOut, value: text)
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
