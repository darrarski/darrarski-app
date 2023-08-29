import ComposableArchitecture
import SwiftUI

@main
struct App: SwiftUI.App {
  let store = Store(initialState: AppReducer.State()) {
    AppReducer()
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
    }
  }
}
