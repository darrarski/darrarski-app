import CustomDump
import InlineSnapshotTesting
import XCTest
@testable import Mastodon

final class JSONObjectTests: XCTestCase {
  func testValue() {
    XCTAssertNoDifference(
      Values(JSONObject.null),
      Values(isNull: true)
    )
    XCTAssertNoDifference(
      Values(JSONObject.bool(true)),
      Values(boolValue: true)
    )
    XCTAssertNoDifference(
      Values(JSONObject.bool(false)),
      Values(boolValue: false)
    )
    XCTAssertNoDifference(
      Values(JSONObject.int(123)),
      Values(intValue: 123)
    )
    XCTAssertNoDifference(
      Values(JSONObject.double(1.5)),
      Values(doubleValue: 1.5)
    )
    XCTAssertNoDifference(
      Values(JSONObject.string("test")),
      Values(stringValue: "test")
    )

    let array: [JSONObject] = [.stub(), .stub()]
    XCTAssertNoDifference(
      Values(JSONObject.array(array)),
      Values(arrayValue: array)
    )
    XCTAssertNoDifference(
      JSONObject.array(array)[0],
      array[0]
    )
    XCTAssertNoDifference(
      JSONObject.array(array)[1],
      array[1]
    )

    let dict: [String: JSONObject] = ["test1": .stub(), "test2": .stub()]
    XCTAssertNoDifference(
      Values(JSONObject.dict(dict)),
      Values(dictValue: dict)
    )
    XCTAssertNoDifference(
      JSONObject.dict(dict)["test1"],
      dict["test1"]
    )
    XCTAssertNoDifference(
      JSONObject.dict(dict).test2,
      dict["test2"]
    )
  }

  func testDebugDescription() {
    XCTAssertNoDifference(
      "\(JSONObject.null)",
      "JSONObject.null"
    )
    XCTAssertNoDifference(
      "\(JSONObject.bool(true))",
      "JSONObject.bool(true)"
    )
    XCTAssertNoDifference(
      "\(JSONObject.int(357))",
      "JSONObject.int(357)"
    )
    XCTAssertNoDifference(
      "\(JSONObject.double(1.5))",
      "JSONObject.double(1.5)"
    )
    XCTAssertNoDifference(
      "\(JSONObject.array([.int(42), .string("test")]))",
      "JSONObject.array([JSONObject.int(42), JSONObject.string(\"test\")])"
    )
    XCTAssertNoDifference(
      "\(JSONObject.dict(["test1": .int(42), "test2": .string("test")]))",
      "JSONObject.dict([\"test1\": JSONObject.int(42), \"test2\": JSONObject.string(\"test\")])"
    )
  }

  func testEncoding() throws {
    let object = JSONObject.dict([
      "null": .null,
      "bool": .bool(true),
      "int": .int(1337),
      "double": .double(1.5),
      "string": .string("test"),
      "array": .array([.int(357), .string("abc")]),
      "dict": .dict(["one": .int(7), "two": .string("abcd")]),
    ])

    assertInlineSnapshot(of: object, as: .json) {
      """
      {
        "array" : [
          357,
          "abc"
        ],
        "bool" : true,
        "dict" : {
          "one" : 7,
          "two" : "abcd"
        },
        "double" : 1.5,
        "int" : 1337,
        "null" : null,
        "string" : "test"
      }
      """
    }
  }

  func testDecoding() throws {
    let jsonString = """
      {
        "array" : [
          357,
          "abc"
        ],
        "bool" : true,
        "dict" : {
          "one" : 7,
          "two" : "abcd"
        },
        "double" : 1.5,
        "int" : 1337,
        "null" : null,
        "string" : "test"
      }
      """

    XCTAssertNoDifference(
      try JSONDecoder().decode(
        JSONObject.self,
        from: jsonString.data(using: .utf8)!
      ),
      JSONObject.dict([
        "null": .null,
        "bool": .bool(true),
        "int": .int(1337),
        "double": .double(1.5),
        "string": .string("test"),
        "array": .array([.int(357), .string("abc")]),
        "dict": .dict(["one": .int(7), "two": .string("abcd")]),
      ])
    )
  }
}


private struct Values: Equatable {
  init(
    isNull: Bool = false,
    boolValue: Bool? = nil,
    intValue: Int? = nil,
    doubleValue: Double? = nil,
    stringValue: String? = nil,
    arrayValue: [JSONObject]? = nil,
    dictValue: [String : JSONObject]? = nil
  ) {
    self.isNull = isNull
    self.boolValue = boolValue
    self.intValue = intValue
    self.doubleValue = doubleValue
    self.stringValue = stringValue
    self.arrayValue = arrayValue
    self.dictValue = dictValue
  }

  init(_ object: JSONObject) {
    self.isNull = object.isNull
    self.boolValue = object.boolValue
    self.intValue = object.intValue
    self.doubleValue = object.doubleValue
    self.stringValue = object.stringValue
    self.arrayValue = object.arrayValue
    self.dictValue = object.dictValue
  }

  var isNull: Bool
  var boolValue: Bool?
  var intValue: Int?
  var doubleValue: Double?
  var stringValue: String?
  var arrayValue: [JSONObject]?
  var dictValue: [String: JSONObject]?
}
