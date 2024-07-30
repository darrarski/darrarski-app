import ComposableArchitecture
import Foundation
import TelemetryClient

typealias AppTelemetryReducerOf<R: Reducer> = AppTelemetryReducer<R.State, R.Action>

@Reducer
struct AppTelemetryReducer<State, Action>: Reducer, Sendable {
  typealias IsEnabled = @Sendable (State, Action) -> Bool

  init(enabled: @escaping IsEnabled = { _, _ in true }) {
    self.isEnabled = enabled
  }
  
  @Dependency(\.appTelemetry) var appTelemetry
  var isEnabled: IsEnabled

  func reduce(into state: inout State, action: Action) -> Effect<Action> {
    guard isEnabled(state, action) else {
      return .none
    }
    let action = UncheckedSendable(action)
    return .run(priority: .low) { send in
      appTelemetry.send(.init(
        name: describe(action.wrappedValue),
        parameters: self.parameters(for: action.wrappedValue)
      ))
    }
  }

  private func describe(_ value: Any, abbreviated: Bool = false) -> String {
    let mirror = Mirror(reflecting: value)
    let prefix = (abbreviated && !(value is any Error)) ? "" : typeName(type(of: value))
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

  private func parameters(for value: Any) -> [String: String] {
    var parameters: [String: String] = [:]
    if let error = value as? any Error {
      parameters["error.localizedDescription"] = error.localizedDescription
      let nsError = error as NSError
      parameters["error.domain"] = nsError.domain
      parameters["error.code"] = "\(nsError.code)"
    }
    if let providedParameters = (value as? any AppTelemetryParametersProviding)?.appTelemetryParameters {
      parameters.addParameters(providedParameters)
    }
    let mirror = Mirror(reflecting: value)
    switch mirror.displayStyle {
    case .enum:
      if let child = mirror.children.first {
        let childParameters = self.parameters(for: child.value)
        parameters.addParameters(childParameters)
      }
    case .optional:
      if let child = mirror.children.first {
        parameters = self.parameters(for: child.value)
      }
    case .tuple:
      for (_, value) in mirror.children {
        let childParameters = self.parameters(for: value)
        parameters.addParameters(childParameters)
      }
    default:
      break
    }
    return parameters
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
  mutating func addParameters(_ parameters: [String: String]) {
    for (key, value) in parameters {
      addParameter(key, value)
    }
  }

  mutating func addParameter(_ key: String, _ value: String) {
    if self[key] == nil {
      self[key] = value
    } else if let match = key.matches(of: #/^(?<key>.*)_(?<number>[0-9]+)$/#).first {
      let duplicateKey = match.output.key
      let nextNumber = (Int(match.output.number) ?? 0) + 1
      addParameter("\(duplicateKey)_\(nextNumber)", value)
    } else {
      addParameter("\(key)_1", value)
    }
  }
}
