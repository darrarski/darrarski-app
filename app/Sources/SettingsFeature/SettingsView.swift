import AppShared
import ComposableArchitecture
import SwiftUI

@ViewAction(for: SettingsReducer.self)
public struct SettingsView: View {
  public init(store: StoreOf<SettingsReducer>) {
    self.store = store
  }

  public let store: StoreOf<SettingsReducer>

  public var body: some View {
    Form {
      Section {
        ColorPicker(selection: Binding(
          get: { store.theme.tintColor },
          set: { send(.tintColorChanged($0), transaction: $1) }
        )) {
          Text("Tint color")
        }

        Picker(selection: Binding(
          get: { store.theme.colorScheme },
          set: { send(.colorSchemeChanged($0), transaction: $1) }
        )) {
          ForEach(AppTheme.ColorScheme.allCases, id: \.self) { colorScheme in
            Group {
              switch colorScheme {
              case .light:
                Text("Light")
              case .dark:
                Text("Dark")
              case .system:
                Text("System")
              }
            }
            .tag(colorScheme)
          }
        } label: {
          Text("Color scheme")
        }

        Button(role: .destructive) {
          send(.resetThemeTapped)
        } label: {
          Text("Reset")
        }
      } header: {
        Text("App theme")
      }
    }
  }

  struct Form<Content: View>: View {
    init(@ViewBuilder content: () -> Content) {
      self.content = content()
    }

    var content: Content

    var body: some View {
      Group {
#if os(macOS)
        ScrollView(.vertical) {
          SwiftUI.Form {
            content
          }
          .frame(maxWidth: 200)
          .padding()
        }
#elseif os(iOS)
        SwiftUI.Form {
          content
        }
#endif
      }
    }
  }
}

#Preview {
  struct Preview: SwiftUI.View {
    let store = Store(initialState: SettingsReducer.State()) {
      SettingsReducer()
    }

    var body: some View {
      SettingsView(store: store)
        .appTheme(store.theme)
    }
  }

  return Preview()
}
