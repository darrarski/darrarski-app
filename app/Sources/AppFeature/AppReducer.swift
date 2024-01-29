import ComposableArchitecture
import ContactFeature
import FeedFeature
import Foundation
import ProjectsFeature

@Reducer
public struct AppReducer: Reducer, Sendable {
  @ObservableState
  public struct State: Equatable {
    public enum Section: Equatable, CaseIterable {
      case contact
      case feed
      case projects
    }

    public init(
      contact: ContactReducer.State = .init(),
      feed: FeedReducer.State = .init(),
      projects: ProjectsReducer.State = .init(),
      selectedSection: Section = .contact
    ) {
      self.contact = contact
      self.feed = feed
      self.projects = projects
      self.selectedSection = selectedSection
    }

    var contact: ContactReducer.State
    var feed: FeedReducer.State
    var projects: ProjectsReducer.State
    var selectedSection: Section
  }

  public enum Action: ViewAction {
    case contact(ContactReducer.Action)
    case feed(FeedReducer.Action)
    case projects(ProjectsReducer.Action)
    case view(View)

    @CasePathable
    public enum View {
      case sectionSelected(State.Section?)
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Scope(state: \.contact, action: \.contact) {
      ContactReducer()
    }
    Scope(state: \.feed, action: \.feed) {
      FeedReducer()
    }
    Scope(state: \.projects, action: \.projects) {
      ProjectsReducer()
    }

    Reduce<State, Action> { state, action in
      switch action {
      case .contact(_), .feed(_), .projects(_):
        return .none

      case .view(.sectionSelected(let section)):
        if let section {
          state.selectedSection = section
        } else {
          state.selectedSection = .contact
        }
        return .none
      }
    }
  }
}
