import ComposableArchitecture

public struct ProjectsReducer: Reducer, Sendable {
  public struct State: Equatable {
    public init(
      info: ProjectsInfo? = nil,
      groups: IdentifiedArrayOf<ProjectsGroup> = [],
      isLoading: Bool = false
    ) {
      self.groups = groups
      self.isLoading = isLoading
    }

    var info: ProjectsInfo?
    var groups: IdentifiedArrayOf<ProjectsGroup>
    var isLoading: Bool

    var projects: IdentifiedArrayOf<Project> {
      IdentifiedArray(uniqueElements: groups.flatMap(\.projects))
    }
  }

  public enum Action: Equatable, Sendable {
    case fetch
    case fetchFinished
    case fetchInfoResult(TaskResult<ProjectsInfo>)
    case fetchProjectsResult(TaskResult<[Project]>)
    case view(View)

    public enum View: Equatable, Sendable {
      case projectCardTapped(Project.ID)
      case refreshButtonTapped
      case refreshTask
      case task
    }
  }

  public init() {}

  @Dependency(\.projectsProvider) var projectsProvider
  @Dependency(\.openURL) var openURL

  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      enum CancelId { case fetch }

      switch action {
      case .fetch:
        state.isLoading = true
        return .run { send in
          await send(.fetchInfoResult(TaskResult {
            try await projectsProvider.fetchInfo()
          }))
          await send(.fetchProjectsResult(TaskResult {
            try await projectsProvider.fetchProjects()
          }))
          await send(.fetchFinished)
        }.cancellable(id: CancelId.fetch, cancelInFlight: true)

      case .fetchFinished:
        state.isLoading = false
        return .none

      case .fetchInfoResult(.success(let info)):
        state.info = info
        return .none

      case .fetchInfoResult(.failure(_)):
        return .none

      case .fetchProjectsResult(.success(let projects)):
        state.groups = .init(groupingByYear: .init(uniqueElements: projects))
        return .none

      case .fetchProjectsResult(.failure(_)):
        return .none

      case .view(.projectCardTapped(let projectId)):
        if let url = state.projects[id: projectId]?.url {
          return .run { _ in await openURL(url) }
        }
        return .none

      case .view(.refreshButtonTapped):
        return .send(.fetch)

      case .view(.refreshTask):
        return .send(.fetch)

      case .view(.task):
        return .send(.fetch)
      }
    }
  }
}
