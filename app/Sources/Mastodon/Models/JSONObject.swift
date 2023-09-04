import Foundation

@dynamicMemberLookup
public enum JSONObject: Equatable, Sendable {
  case null
  case bool(Bool)
  case int(Int)
  case double(Double)
  case string(String)
  case array([JSONObject])
  case dict([String: JSONObject])
}

extension JSONObject {
  public var isNull: Bool {
    self == .null
  }

  public var boolValue: Bool? {
    guard case .bool(let value) = self else { return nil }
    return value
  }

  public var intValue: Int? {
    guard case .int(let value) = self else { return nil }
    return value
  }

  public var doubleValue: Double? {
    guard case .double(let value) = self else { return nil }
    return value
  }

  public var stringValue: String? {
    guard case .string(let value) = self else { return nil }
    return value
  }

  public var arrayValue: [JSONObject]? {
    guard case .array(let value) = self else { return nil }
    return value
  }

  public var dictValue: [String: JSONObject]? {
    guard case .dict(let value) = self else { return nil }
    return value
  }
}

extension JSONObject {
  public subscript(_ arrayIndex: [JSONObject].Index) -> JSONObject? {
    arrayValue?[arrayIndex]
  }

  public subscript(_ dictKey: String) -> JSONObject? {
    dictValue?[dictKey]
  }

  public subscript(dynamicMember string: String) -> JSONObject? {
    dictValue?[string]
  }
}

extension JSONObject: CustomDebugStringConvertible {
  public var debugDescription: String {
    switch self {
    case .null:
      return "\(Self.self).null"
    case .bool(let value):
      return "\(Self.self).bool(\(value.description))"
    case .int(let value):
      return "\(Self.self).int(\(value))"
    case .double(let value):
      return "\(Self.self).double(\(value))"
    case .string(let value):
      return "\(Self.self).string(\"\(value)\")"
    case .array(let value):
      return "\(Self.self).array(\(value.debugDescription))"
    case .dict(let value):
      return "\(Self.self).dict(\(value.debugDescription))"
    }
  }
}

extension JSONObject: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if container.decodeNil() {
      self = .null
    } else if let value = try? container.decode(Bool.self) {
      self = .bool(value)
    } else if let value = try? container.decode(Int.self) {
      self = .int(value)
    } else if let value = try? container.decode(Double.self) {
      self = .double(value)
    } else if let value = try? container.decode(String.self) {
      self = .string(value)
    } else if let value = try? container.decode([JSONObject].self) {
      self = .array(value)
    } else if let value = try? container.decode([String: JSONObject].self) {
      self = .dict(value)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container,
        debugDescription: "Unexpected type"
      )
    }
  }
}

extension JSONObject: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .null: try container.encodeNil()
    case .bool(let value): try container.encode(value)
    case .int(let value): try container.encode(value)
    case .double(let value): try container.encode(value)
    case .string(let value): try container.encode(value)
    case .array(let value): try container.encode(value)
    case .dict(let value): try container.encode(value)
    }
  }
}
