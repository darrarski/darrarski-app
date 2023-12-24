import ComposableArchitecture
import ContactFeature
import FeedFeature
import Foundation
import ProjectsFeature
import SettingsFeature

@Reducer
public struct AppReducer: Reducer, Sendable {
  @ObservableState
  public struct State: Equatable {
    public enum Section: Equatable, CaseIterable {
      case contact
      case feed
      case projects
      case settings
    }

    public init(
      contact: ContactReducer.State = .init(),
      feed: FeedReducer.State = .init(),
      projects: ProjectsReducer.State = .init(),
      settings: SettingsReducer.State = .init(),
      selectedSection: Section = .contact
    ) {
      self.contact = contact
      self.feed = feed
      self.projects = projects
      self.settings = settings
      self.selectedSection = selectedSection
    }

    var contact: ContactReducer.State
    var feed: FeedReducer.State
    var projects: ProjectsReducer.State
    var settings: SettingsReducer.State
    var selectedSection: Section
  }

  public enum Action: ViewAction {
    case contact(ContactReducer.Action)
    case feed(FeedReducer.Action)
    case projects(ProjectsReducer.Action)
    case settings(SettingsReducer.Action)
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
    Scope(state: \.settings, action: \.settings) {
      SettingsReducer()
    }

    Reduce<State, Action> { state, action in
      switch action {
      case .contact(_), .feed(_), .projects(_), .settings(_):
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
