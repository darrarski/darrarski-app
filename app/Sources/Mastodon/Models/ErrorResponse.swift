import Foundation

/// Represents API error response
public struct ErrorResponse: Error, Equatable, Sendable {
  public init(statusCode: Int?, data: Data) {
    self.statusCode = statusCode
    self.data = data
  }
  
  public var statusCode: Int?
  public var data: Data
}

extension ErrorResponse: LocalizedError {
  public var errorDescription: String? {
    let statusCodeString = statusCode.map { "\($0)" } ?? "?"
    let dataString = String(data: data, encoding: .utf8) ?? "\(String(describing: data))"
    return "\(statusCodeString): \(dataString)"
  }
}
