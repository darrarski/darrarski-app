import ComposableArchitecture
import Mastodon
import SwiftUI

public struct StatusView: View {
  public init(store: StoreOf<StatusReducer>) {
    self.store = store
  }

  let store: StoreOf<StatusReducer>

  public var body: some View {
    Text("StatusView").padding()
  }
}

#Preview {
  StatusView(store: Store(initialState: StatusReducer.State(
    status: [Status].preview[0]
  )) {
    StatusReducer()
  })
}
