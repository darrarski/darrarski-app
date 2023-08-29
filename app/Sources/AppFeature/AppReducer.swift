import ComposableArchitecture
import ContactFeature
import FeedFeature
import Foundation
import ProjectsFeature

public struct AppReducer: Reducer {
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

  public enum Action: Equatable {
    case contact(ContactReducer.Action)
    case feed(FeedReducer.Action)
    case projects(ProjectsReducer.Action)
    case view(View)

    public enum View: Equatable {
      case sectionSelected(State.Section?)
    }
  }

  public init() {}

  public var body: some ReducerOf<Self> {
    Scope(state: \.contact, action: /Action.contact) {
      ContactReducer()
    }
    Scope(state: \.feed, action: /Action.feed) {
      FeedReducer()
    }
    Scope(state: \.projects, action: /Action.projects) {
      ProjectsReducer()
    }

    Reduce { state, action in
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
