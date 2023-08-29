import ComposableArchitecture
import SwiftUI

public struct ContactView: View {
  public init(store: StoreOf<ContactReducer>) {
    self.store = store
  }

  let store: StoreOf<ContactReducer>

  public var body: some View {
    Text("ContactView")
  }
}

#Preview {
  ContactView(store: Store(initialState: ContactReducer.State()) {
    ContactReducer()
  })
}
