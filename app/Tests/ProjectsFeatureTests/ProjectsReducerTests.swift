import ComposableArchitecture
import XCTest
@testable import ProjectsFeature

@MainActor
final class ProjectsReducerTests: XCTestCase {
  func testFetch() async {
    let clock = TestClock()
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.continuousClock = clock
      $0.projectsProvider.fetchInfo = { .preview }
      $0.projectsProvider.fetchProjects = { .preview }
    }

    await store.send(.fetch) {
      $0.isLoading = true
    }
    await clock.advance(by: .seconds(0.5))
    await store.receive(.fetchInfoResult(.success(.preview))) {
      $0.info = .preview
    }
    await store.receive(.fetchProjectsResult(.success(.preview))) {
      $0.groups = .init(groupingByYear: .init(uniqueElements: [Project].preview))
    }
    await store.receive(.fetchFinished) {
      $0.isLoading = false
    }
  }

  func testFetchInfoFailure() async {
    let error = NSError(domain: "test", code: 1234)
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.projectsProvider.fetchInfo = { throw error }
      $0.projectsProvider.fetchProjects = { .preview }
    }

    await store.send(.fetch) {
      $0.isLoading = true
    }
    await store.receive(.fetchInfoResult(.failure(error)))
    await store.receive(.fetchProjectsResult(.success(.preview))) {
      $0.groups = .init(groupingByYear: .init(uniqueElements: [Project].preview))
    }
    await store.receive(.fetchFinished) {
      $0.isLoading = false
    }
  }

  func testFetchProjectsFailure() async {
    let error = NSError(domain: "test", code: 1234)
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.projectsProvider.fetchInfo = { .preview }
      $0.projectsProvider.fetchProjects = { throw error }
    }

    await store.send(.fetch) {
      $0.isLoading = true
    }
    await store.receive(.fetchInfoResult(.success(.preview))) {
      $0.info = .preview
    }
    await store.receive(.fetchProjectsResult(.failure(error)))
    await store.receive(.fetchFinished) {
      $0.isLoading = false
    }
  }

  func testViewRefreshButtonTapped() async {
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.projectsProvider.fetchInfo = { .preview }
      $0.projectsProvider.fetchProjects = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshButtonTapped))
    await store.receive(.fetch)
  }

  func testViewRefreshTask() async {
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.projectsProvider.fetchInfo = { .preview }
      $0.projectsProvider.fetchProjects = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.refreshTask))
    await store.receive(.fetch)
  }

  func testViewTask() async {
    let store = TestStore(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    } withDependencies: {
      $0.continuousClock = ImmediateClock()
      $0.projectsProvider.fetchInfo = { .preview }
      $0.projectsProvider.fetchProjects = { .preview }
    }
    store.exhaustivity = .off

    await store.send(.view(.task))
    await store.receive(.fetch)
  }

  func testViewProjectCardTapped() async {
    let didOpenURL = ActorIsolated<[URL]>([])
    let projects = IdentifiedArray(uniqueElements: [Project].preview)
    let project = projects.first { $0.url != nil }!
    let store = TestStore(initialState: ProjectsReducer.State(
      groups: .init(groupingByYear: projects)
    )) {
      ProjectsReducer()
    } withDependencies: {
      $0.openURL = .init { url in
        await didOpenURL.withValue { $0.append(url) }
        return true
      }
    }

    await store.send(.view(.projectCardTapped(project.id)))
    await didOpenURL.withValue {
      XCTAssertNoDifference($0, [project.url!])
    }
  }
}
