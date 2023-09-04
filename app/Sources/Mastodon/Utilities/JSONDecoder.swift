import Foundation

extension JSONDecoder {
  public static let mastodon: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    decoder.dateDecodingStrategy = .custom { decoder in
      let container = try decoder.singleValueContainer()
      let string = try container.decode(String.self)
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
      if let date = formatter.date(from: string) {
        return date
      }
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
      formatter.timeZone = TimeZone(secondsFromGMT: 0)
      if let date = formatter.date(from: string) {
        return date
      }
      formatter.dateFormat = "yyyy-MM-dd"
      formatter.timeZone = .current
      if let date = formatter.date(from: string) {
        return date
      }
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: #"Unknown date format: "\#(string)""#
      )
    }
    return decoder
  }()
}
