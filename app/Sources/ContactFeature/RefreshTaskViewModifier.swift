import SwiftUI

extension View {
  /// Make the view refreshable and define a refresh task action.
  ///
  /// The task is automatically identified to persist refreshing state when the view is reloaded.
  ///
  /// - Parameter action: Async refresh action
  /// - Returns: Refreshable view
  public func refreshTask(action: @escaping () async -> Void) -> some View {
    modifier(RefreshTaskViewModifier(action: action))
  }
}

struct RefreshTaskViewModifier: ViewModifier {
  var action: () async -> Void
  @State var taskId: UUID?

  func body(content: Content) -> some View {
    content
      .refreshable {
        taskId = .init()
        while taskId != nil { await Task.yield() }
      }
      .task(id: taskId, priority: .userInitiated) {
        guard taskId != nil else { return }
        await action()
        taskId = nil
      }
  }
}
