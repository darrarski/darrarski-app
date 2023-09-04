import CustomDump
import XCTest
@testable import Mastodon

final class IndirectTests: XCTestCase {
struct Model: Codable, Equatable {
  var id: Int
  var next: Indirect<Model>?
}

  func testEncoding() throws {
    let model = Model(
      id: 1,
      next: Indirect(Model(
        id: 2,
        next: Indirect(Model(
          id: 3
        ))
      ))
    )
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    let jsonData = try encoder.encode(model)
    let jsonString = String(data: jsonData, encoding: .utf8)

    XCTAssertNoDifference(jsonString, #"{"id":1,"next":{"id":2,"next":{"id":3}}}"#)
  }

  func testDecoding() throws {
    let jsonString = #"{"id":1,"next":{"id":2,"next":{"id":3}}}"#
    let jsonData = jsonString.data(using: .utf8)!
    let decoder = JSONDecoder()
    let model = try decoder.decode(Model.self, from: jsonData)

    XCTAssertNoDifference(
      model,
      Model(
        id: 1,
        next: Indirect(Model(
          id: 2,
          next: Indirect(Model(
            id: 3
          ))
        ))
      )
    )
  }
}
