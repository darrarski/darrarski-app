import ComposableArchitecture
import TelemetryClient

typealias AppTelemetryReducerOf<R: Reducer> = AppTelemetryReducer<R.State, R.Action>

struct AppTelemetryReducer<State, Action>: Reducer {
  @Dependency(\.appTelemetry) var appTelemetry

  func reduce(into _: inout State, action: Action) -> Effect<Action> {
    let action = UncheckedSendable(action)
    return .run(priority: .low) { send in
      let event = describe(action.wrappedValue)
      appTelemetry.send(event)
    }
  }

  private func describe(_ value: Any, abbreviated: Bool = false) -> String {
    let mirror = Mirror(reflecting: value)
    let prefix = (abbreviated && !(value is Error)) ? "" : typeName(type(of: value))
    switch mirror.displayStyle {
    case .enum:
      if let child = mirror.children.first {
        let childPath = describe(child.value, abbreviated: true)
        return "\(prefix).\(child.label ?? "")\(childPath.isEmpty ? "" : "(\(childPath))")"
      } else {
        return "\(prefix).\(value)"
      }
    case .optional:
      if let child = mirror.children.first {
        return ".some(\(describe(child.value, abbreviated: true)))"
      } else {
        return "\(prefix).none"
      }
    default:
      return "\(typeName(mirror.subjectType))"
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
}
