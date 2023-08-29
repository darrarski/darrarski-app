import ComposableArchitecture
import SwiftUI

public struct AppView: View {
  public init(store: StoreOf<AppReducer>) {
    self.store = store
  }

  let store: StoreOf<AppReducer>

  public var body: some View {
    Text("AppView")
  }
}

#Preview {
  AppView(store: Store(initialState: AppReducer.State()) {
    AppReducer()
  })
}
