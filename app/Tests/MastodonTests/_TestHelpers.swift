import Foundation
@testable import Mastodon

extension HTTPURLResponse {
  static func stub(_ statusCode: Int) -> HTTPURLResponse {
    HTTPURLResponse(
      url: URL(string: "stub")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: nil
    )!
  }
}

extension JSONObject {
  static func stub() -> JSONObject {
    let stubs: [() -> JSONObject] = [
      { .bool(.random()) },
      { .int(.random(in: 100_000...999_999)) },
      { .double(.random(in: 100_000...999_999)) },
      { .string(UUID().uuidString) },
      { .array([.stub()]) },
      { .dict(["stub": .stub()]) },
    ]
    return stubs.randomElement()!()
  }
}

extension Optional<JSONObject> {
  static func stub() -> JSONObject? {
    Bool.random() ? JSONObject.stub() : nil
  }
}
