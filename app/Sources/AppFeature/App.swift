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
    AppTelemetryReducer { _, action in
      switch action {
      case .contact(.fetchContact): false
      case .contact(.fetchContactResult(.failure(_))): true
      case .contact(.fetchContactResult(.success(_))): false
      case .contact(.view(.linkButtonTapped(_))): true
      case .contact(.view(.refreshButtonTapped)): true
      case .contact(.view(.refreshTask)): true
      case .contact(.view(.task)): false
      case .feed(.fetchStatuses): false
      case .feed(.fetchStatusesResult(.failure(_))): true
      case .feed(.fetchStatusesResult(.success(_))): false
      case .feed(.status(.element(_, .quickLookItem(.dismiss)))): true
      case .feed(.status(.element(_, .quickLookItem(.presented(_))))): false
      case .feed(.status(.element(_, .renderText))): false
      case .feed(.status(.element(_, .textRendered(.failure(_))))): true
      case .feed(.status(.element(_, .textRendered(.success(_))))): false
      case .feed(.status(.element(_, .view(.attachmentTapped(_))))): true
      case .feed(.status(.element(_, .view(.headerTapped)))): true
      case .feed(.status(.element(_, .view(.linkTapped(_))))): true
      case .feed(.status(.element(_, .view(.previewCardTapped)))): true
      case .feed(.status(.element(_, .view(.quickLookItemChanged(_))))): true
      case .feed(.status(.element(_, .view(.textTask)))): false
      case .feed(.view(.refreshButtonTapped)): true
      case .feed(.view(.refreshTask)): true
      case .feed(.view(.seeMoreButtonTapped)): true
      case .feed(.view(.task)): false
      case .projects(.fetch): false
      case .projects(.fetchFinished): false
      case .projects(.fetchInfoResult(.failure(_))): true
      case .projects(.fetchInfoResult(.success(_))): false
      case .projects(.fetchProjectsResult(.failure(_))): true
      case .projects(.fetchProjectsResult(.success(_))): false
      case .projects(.view(.projectCardTapped(_))): true
      case .projects(.view(.refreshButtonTapped)): true
      case .projects(.view(.refreshTask)): true
      case .projects(.view(.task)): false
      case .settings(.view(.tintColorChanged(_))): true
      case .settings(.view(.colorSchemeChanged(_))): true
      case .settings(.view(.resetThemeTapped)): true
      case .view(.sectionSelected(_)): true
      }
    }
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
