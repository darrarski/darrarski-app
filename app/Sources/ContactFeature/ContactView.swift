import AppShared
import ComposableArchitecture
import Kingfisher
import SwiftUI

@ViewAction(for: ContactReducer.self)
public struct ContactView: View {
  public init(store: StoreOf<ContactReducer>) {
    self.store = store
  }

  public let store: StoreOf<ContactReducer>
  @State var isRefreshing = false
  let maxContentWidth: CGFloat = 500
#if os(iOS)
  @ScaledMetric var linkButtonIconSize: CGFloat = 24
#elseif os(macOS)
  @ScaledMetric var linkButtonIconSize: CGFloat = 16
#endif

  public var body: some View {
    ScrollView {
      VStack(spacing: 16) {
        header
        content.frame(maxWidth: .infinity, alignment: .leading)
        buttons
      }
      .frame(maxWidth: maxContentWidth)
      .frame(maxWidth: .infinity)
      .padding()
    }
    .task {
      await send(.task).finish()
    }
    .refreshTask {
      isRefreshing = true
      defer { isRefreshing = false }
      await send(.refreshTask).finish()
    }
    .navigationTitle("Darrarski")
    .toolbar {
#if os(macOS)
      ToolbarItem(placement: .primaryAction) {
        Button {
          send(.refreshButtonTapped)
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
  }

  @MainActor
  var header: some View {
    HStack(alignment: .top) {
      AvatarView(url: store.contact?.avatarURL)
      .containerRelativeFrame(.horizontal) { width, _ in
        min(width, maxContentWidth) / 3
      }

      details
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .vertical])
    }
  }

  @MainActor
  var details: some View {
    VStack(alignment: .leading) {
      let name = store.contact?.name ?? "Dariusz Rybicki"

      Text(name)
        .font(.title)
        .redacted(reason: store.contact?.name == nil ? .placeholder : [])
        .animation(.bouncy, value: name)

      let description = store.contact?.description ?? "Redacted Placeholder\nLorem ipsum\nPariatur ex aliqua ut"

      Text(description)
        .font(.headline)
        .redacted(reason: store.contact?.description == nil ? .placeholder : [])
        .animation(.bouncy, value: description)
    }
  }

  @MainActor
  @ViewBuilder
  var content: some View {
    let value = store.contact?.content
    let placeholder = AttributedString("Aliquip in qui enim. Labore incididunt velit qui eu ad cillum culpa enim. In elit sit est officia aliquip consequat nisi incididunt reprehenderit labore consequat id qui est. Veniam velit voluptate occaecat. Aliquip ullamco irure sunt anim sit ad aliqua consectetur Lorem aliquip. Do ullamco nisi ex consequat cillum cupidatat ea commodo consectetur.")
    let text = value ?? placeholder

    Text(text)
      .font(.body)
      .redacted(reason: value == nil ? .placeholder : [])
      .animation(.bouncy, value: text)
  }

  @MainActor
  var buttons: some View {
#if os(iOS)
      AdaptiveGridLayout(spacing: CGSize(width: 16, height: 16)) {
        buttonsGridContent
      }
      .animation(.bouncy, value: (store.contact?.links.map(\.id) ?? []))
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

  @MainActor
  @ViewBuilder
  var buttonsGridContent: some View {
    let links = store.contact?.links ?? []

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

  func linkButton(link: Contact.Link) -> some View {
    Button {
      send(.linkButtonTapped(link))
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
            KFImage(link.iconURL)
              .placeholder {
                Image(systemName: "link")
                  .resizable()
                  .scaledToFit()
                  .scaleEffect(CGSize(width: 0.75, height: 0.75))
                  .opacity(0.5)
              }
              .renderingMode(.template)
              .resizable()
              .scaledToFit()
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
  .appTheme(.default)
}
