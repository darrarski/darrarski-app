/// Wrapper for recursive model relations
///
/// ```swift
/// struct Model {
///   var id: Int
///   var next: Indirect<Model>?
/// }
///
/// let model = Model(id: 1, next: Model(id: 2, next: nil))
/// ```
@dynamicMemberLookup
public enum Indirect<Value> {
  indirect case indirect(Value)

  public init(_ value: Value) {
    self = .indirect(value)
  }

  public var value: Value {
    get {
      switch self {
      case .indirect(let value):
        return value
      }
    }
    set {
      self = .indirect(newValue)
    }
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<Value, T>) -> T {
    value[keyPath: keyPath]
  }

  public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T>) -> T {
    get { value[keyPath: keyPath] }
    set { value[keyPath: keyPath] = newValue }
  }
}

extension Indirect: Equatable where Value: Equatable {}
extension Indirect: Sendable where Value: Sendable {}

extension Indirect: Decodable where Value: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self = .indirect(try container.decode(Value.self))
  }
}

extension Indirect: Encodable where Value: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .indirect(let value):
      try container.encode(value)
    }
  }
}
