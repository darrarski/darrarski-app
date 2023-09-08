import AppShared
import ComposableArchitecture
import SwiftUI

public struct ContactView: View {
  public init(store: StoreOf<ContactReducer>) {
    self.store = store
  }

  let store: StoreOf<ContactReducer>
  let maxContentWidth: CGFloat = 500
#if os(iOS)
  @ScaledMetric var linkButtonIconSize: CGFloat = 24
#elseif os(macOS)
  @ScaledMetric var linkButtonIconSize: CGFloat = 16
#endif

  public var body: some View {
    ScrollView {
      VStack {
        header
        buttons
      }
      .frame(maxWidth: maxContentWidth)
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
    HStack(alignment: .top) {
      WithViewStore(store, observe: \.contact?.avatarURL) { viewStore in
        AvatarView(url: viewStore.state)
      }
      .containerRelativeFrame(.horizontal) { width, _ in
        min(width, maxContentWidth) / 3
      }
      .padding(.bottom)

      details
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .vertical])
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
    WithViewStore(store, observe: { $0.contact?.links.map(\.id) ?? [] }) { viewStore in
#if os(iOS)
      AdaptiveGridLayout(spacing: CGSize(width: 16, height: 16)) {
        buttonsGridContent
      }
      .animation(.bouncy, value: viewStore.state)
#elseif os(macOS)
      LazyVGrid(
        columns: [
          GridItem(
            .adaptive(minimum: 150, maximum: 200),
            spacing: 16
          ),
        ],
        alignment: .leading,
        spacing: 16
      ) {
        buttonsGridContent
      }
#endif
    }
  }

  @MainActor
  var buttonsGridContent: some View {
    WithViewStore(store, observe: { $0.contact?.links ?? [] }) { viewStore in
      let links = viewStore.state

      if links.isEmpty {
        let placeholders = [
          "Blob 123",
          "Culpa irure mag",
          "Placeholder",
          "Lorem Ipsum",
          "Lorem",
        ]
        ForEach(0..<4) { index in
          linkButton(link: .init(
            id: "placeholder-\(index)",
            title: placeholders[index % placeholders.count],
            url: URL(filePath: ""),
            iconURL: nil,
            target: .system
          ))
        }
        .disabled(true)
        .redacted(reason: [.placeholder])
      } else {
        ForEach(links) { link in
          linkButton(link: link)
            .transition(.asymmetric(
              insertion: .scale.combined(with: .opacity),
              removal: .opacity
            ))
        }
      }
    }
  }

  func linkButton(link: Contact.Link) -> some View {
    Button {
      store.send(.view(.linkButtonTapped(link)))
    } label: {
      Label {
        Text(link.title)
          .font(.callout.bold())
          .lineLimit(1)

      } icon: {
        Group {
          if let iconURL = link.iconURL,
             let symbolURL = SFSymbolURL(iconURL) {
            Image(systemName: symbolURL.name)
              .symbolRenderingMode(symbolURL.rendering)
              .resizable()
              .scaledToFit()

          } else {
            AsyncImage(url: link.iconURL) { image in
              image
                .renderingMode(.template)
                .resizable()
                .scaledToFit()

            } placeholder: {
              Image(systemName: "link")
                .resizable()
                .scaledToFit()
                .scaleEffect(CGSize(width: 0.75, height: 0.75))
                .opacity(0.5)
            }
          }
        }
        .frame(width: linkButtonIconSize)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .controlSize(.large)
    .buttonStyle(.borderedProminent)
  }
}

#Preview {
  NavigationStack {
    ContactView(store: Store(initialState: ContactReducer.State()) {
      ContactReducer()
    })
  }
  .tint(.appTint)
}
