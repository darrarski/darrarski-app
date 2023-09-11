import Kingfisher
import SwiftUI

struct AvatarView: View {
  var url: URL?
  @State var didLoad = false

  var body: some View {
    let scale = didLoad ? 1.0 : 0.0
    let opactity = didLoad ? 1.0 : 0.0
    
    ZStack {
      KFImage(url)
        .resizable()
        .placeholder {
          Color.clear
        }
        .onSuccess { _ in
          didLoad = true
        }
        .aspectRatio(contentMode: .fit)
        .clipShape(Circle())
        .scaleEffect(x: scale, y: scale, anchor: .center)
        .opacity(opactity)
        .transition(.asymmetric(insertion: .identity, removal: .opacity))
    }
    .animation(.bouncy, value: didLoad)
    .onChange(of: url) { _, _ in didLoad = false }

    .background(Color.secondary.opacity(0.2))
    .clipShape(Circle())
    .shadow(color: .appTint, radius: 10, x: 0, y: 0)
  }
}
