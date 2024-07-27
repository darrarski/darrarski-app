import Foundation
import IdentifiedCollections

public struct ProjectsGroup: Equatable, Sendable {
  public init(
    date: Date,
    projects: IdentifiedArrayOf<Project>
  ) {
    self.date = date
    self.projects = projects
  }

  public var date: Date
  public var projects: IdentifiedArrayOf<Project>
}

extension ProjectsGroup: Identifiable {
  public struct ID: Hashable, Sendable {
    public init(date: Date) {
      self.date = date
    }

    public var date: Date
  }

  public var id: ID { ID(date: date) }
}

extension IdentifiedArrayOf<ProjectsGroup> {
  public init(
    groupingByYear projects: IdentifiedArrayOf<Project>,
    calendar: Calendar = .current
  ) {
    self = .init(
      uniqueElements: Dictionary<Int, [Project]>(
        grouping: projects,
        by: { calendar.component(.year, from: $0.date) }
      )
      .map { (year: Int, projects: [Project]) -> ProjectsGroup  in
        ProjectsGroup(
          date: calendar.date(from: DateComponents(year: year))!,
          projects: .init(
            uniqueElements: projects.sorted { $0.date > $1.date }
          )
        )
      }
      .sorted { $0.date > $1.date }
    )
  }
}
