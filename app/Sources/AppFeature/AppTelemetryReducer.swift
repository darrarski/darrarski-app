import ComposableArchitecture
import Foundation
import TelemetryClient

typealias AppTelemetryReducerOf<R: Reducer> = AppTelemetryReducer<R.State, R.Action>

struct AppTelemetryReducer<State, Action>: Reducer {
  @Dependency(\.appTelemetry) var appTelemetry

  func reduce(into _: inout State, action: Action) -> Effect<Action> {
    let action = UncheckedSendable(action)
    return .run(priority: .low) { send in
      appTelemetry.send(.init(
        type: describe(action.wrappedValue),
        payload: payload(for: action.wrappedValue)
      ))
    }
  }

  private func describe(_ value: Any, abbreviated: Bool = false) -> String {
    let mirror = Mirror(reflecting: value)
    let prefix = (abbreviated && !(value is Error)) ? "" : typeName(type(of: value))
    switch mirror.displayStyle {
    case .enum:
      if let child = mirror.children.first {
        let childLabel = child.label ?? ""
        let childOutput = describe(child.value, abbreviated: true)
          .nonEmpty.map { "(\($0))" } ?? ""
        return "\(prefix).\(childLabel)\(childOutput)"
      } else {
        return "\(prefix).\(value)"
      }
    case .optional:
      if let child = mirror.children.first {
        return ".some(\(describe(child.value, abbreviated: true)))"
      } else {
        return "\(prefix).none"
      }
    case .tuple:
      return mirror.children.map { label, value in
        let childLabel = toupleChildLabel(label).map { "\($0):" }
        let childOutput = describe(value, abbreviated: true).nonEmpty
        return [childLabel, childOutput].compactMap { $0 } .joined(separator: " ")
      }
      .joined(separator: ", ")
    default:
      return typeName(mirror.subjectType)
    }
  }

  private func typeName(_ type: Any.Type) -> String {
    var name = _typeName(type, qualified: true)
    if let index = name.firstIndex(of: ".") {
      name.removeSubrange(...index)
    }
    let sanitizedName = name.replacingOccurrences(
      of: #"<.+>|\(unknown context at \$[[:xdigit:]]+\)\."#,
      with: "",
      options: .regularExpression
    )
    return sanitizedName
  }

  private func payload(for value: Any) -> [String: String] {
    var payload: [String: String] = [:]
    if let error = value as? Error {
      payload["error.localizedDescription"] = error.localizedDescription
      let nsError = error as NSError
      payload["error.domain"] = nsError.domain
      payload["error.code"] = "\(nsError.code)"
    }
    if let providedPayload = (value as? AppTelemetryPayloadProviding)?.appTelemetryPayload {
      payload.addPayload(providedPayload)
    }
    let mirror = Mirror(reflecting: value)
    switch mirror.displayStyle {
    case .enum:
      if let child = mirror.children.first {
        let childPayload = self.payload(for: child.value)
        payload.addPayload(childPayload)
      }
    case .optional:
      if let child = mirror.children.first {
        payload = self.payload(for: child.value)
      }
    case .tuple:
      for (_, value) in mirror.children {
        let childPayload = self.payload(for: value)
        payload.addPayload(childPayload)
      }
    default:
      break
    }
    return payload
  }

  private func toupleChildLabel(_ label: String?) -> String? {
    guard let label else { return nil }
    let isUnlabeled = label.matches(of: #/^\.[0-9]+$/#).first != nil
    return isUnlabeled ? nil : label
  }
}

private extension Collection {
  var nonEmpty: Self? { isEmpty ? nil : self }
}

private extension [String: String] {
  mutating func addPayload(_ payload: [String: String]) {
    for (key, value) in payload {
      addPayload(key, value)
    }
  }

  mutating func addPayload(_ key: String, _ value: String) {
    if self[key] == nil {
      self[key] = value
    } else if let match = key.matches(of: #/^(?<key>.*)_(?<number>[0-9]+)$/#).first {
      let duplicateKey = match.output.key
      let nextNumber = (Int(match.output.number) ?? 0) + 1
      addPayload("\(duplicateKey)_\(nextNumber)", value)
    } else {
      addPayload("\(key)_1", value)
    }
  }
}
