import Foundation

public struct Project: Equatable, Sendable, Decodable {
  public init(
    date: Date,
    type: String,
    name: String,
    tags: [String],
    url: URL?
  ) {
    self.date = date
    self.type = type
    self.name = name
    self.tags = tags
    self.url = url
  }

  @ProjectDate public var date: Date
  public var type: String
  public var name: String
  public var tags: [String]
  public var url: URL?
}

extension Project {
  @propertyWrapper
  public struct ProjectDate: Equatable, Sendable {
    public init(wrappedValue: Date) {
      self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Foundation.Date
  }
}

extension Project.ProjectDate: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let string = try container.decode(String.self)
    guard let date = Self.dateFormatter.date(from: string) else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: #"Invalid date format: "\#(string)""#
      )
    }
    self.wrappedValue = date
  }

  static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    return formatter
  }()
}

extension Array<Project> {
  public static let preview: [Project] = {
    let url = Bundle.module.url(forResource: "projects_preview", withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    return try! decoder.decode([Project].self, from: data)
  }()
}
