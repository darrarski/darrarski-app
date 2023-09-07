import ComposableArchitecture

public struct ProjectsReducer: Reducer, Sendable {
  public struct State: Equatable {
    public init(
      projects: [Project] = [],
      isLoading: Bool = false
    ) {
      self.projects = projects
      self.isLoading = isLoading
    }

    var projects: [Project]
    var isLoading: Bool
  }

  public enum Action: Equatable, Sendable {
    case fetchProjects
    case fetchProjectsResult(TaskResult<[Project]>)
    case view(View)

    public enum View: Equatable, Sendable {
      case refreshButtonTapped
      case refreshTask
      case task
    }
  }

  public init() {}

  @Dependency(\.projectsProvider) var projectsProvider

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      enum CancelId { case fetchProjects }

      switch action {
      case .fetchProjects:
        state.isLoading = true
        return .run { send in
          await send(.fetchProjectsResult(TaskResult {
            try await projectsProvider.fetch()
          }))
        }.cancellable(id: CancelId.fetchProjects, cancelInFlight: true)

      case .fetchProjectsResult(let result):
        state.isLoading = false
        switch result {
        case .success(let projects):
          state.projects = projects
        case .failure(_):
          break
        }
        return .none

      case .view(.refreshButtonTapped):
        return .send(.fetchProjects)

      case .view(.refreshTask):
        return .send(.fetchProjects)

      case .view(.task):
        return .send(.fetchProjects)
      }
    }
  }
}
