import ComposableArchitecture
import SwiftUI

public struct SettingsView: View {
  public init(store: StoreOf<SettingsReducer>) {
    self.store = store
  }

  let store: StoreOf<SettingsReducer>

  public var body: some View {
    Text("SettingsView")
  }
}

#Preview {
  SettingsView(store: Store(initialState: SettingsReducer.State()) {
    SettingsReducer()
  })
}
