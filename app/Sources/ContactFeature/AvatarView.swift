import SwiftUI

struct AvatarView: View {
  var url: URL?
  @State var didAppear = false

  var body: some View {
    AsyncImage(url: url) { image in
      let scale = didAppear ? 1.0 : 0.0
      let opactity = didAppear ? 1.0 : 0.0

      image
        .resizable()
        .clipShape(Circle())
        .scaleEffect(x: scale, y: scale, anchor: .center)
        .opacity(opactity)
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
        .task { didAppear = true }

    } placeholder: {
      Image(systemName: "person")
        .resizable()
        .bold()
        .scaleEffect(CGSize(width: 0.5, height: 0.5), anchor: .center)
        .padding(-10)
    }
    .animation(.bouncy, value: didAppear)
    .onChange(of: url) { _, _ in didAppear = false }
    .aspectRatio(contentMode: .fit)
    .background(Color.secondary)
    .clipShape(Circle())
    .shadow(color: .accentColor, radius: 10, x: 0, y: 0)
  }
}
