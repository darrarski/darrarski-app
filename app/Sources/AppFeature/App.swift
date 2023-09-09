import ComposableArchitecture
import SwiftUI

@main
struct App: SwiftUI.App {
  init() {
    appTelemetry.initialize()
    appTelemetry.send("App.init")
  }

  @Dependency(\.appTelemetry) var appTelemetry
  let store = Store(initialState: AppReducer.State()) {
    AppReducer()
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
    }
  }
}
