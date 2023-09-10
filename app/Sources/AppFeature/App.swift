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
    AppTelemetryReducer()
  } withDependencies: {
    $0.openURL = .init { [dependencies = $0] url in
      defer {
        dependencies.appTelemetry.send(.init(
          type: "OpenURL",
          payload: ["url": url.absoluteString]
        ))
      }
      return await dependencies.openURL(url)
    }
  }

  var body: some Scene {
    WindowGroup {
      AppView(store: store)
    }
  }
}
