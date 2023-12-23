import AppShared
import ComposableArchitecture
import SwiftUI

public struct SettingsView: View {
  public init(store: StoreOf<SettingsReducer>) {
    self.store = store
  }

  let store: StoreOf<SettingsReducer>

  public var body: some View {
    Form {
      AppThemeSection(store: store.scope(state: \.theme, action: \.theme))
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

  struct AppThemeSection: View {
    let store: AppThemeStore

    var body: some View {
      Section {
        ColorPicker(selection: Binding(
          get: { store.tintColor },
          set: { store.send(.set(\.tintColor, $0), transaction: $1) }
        )) {
          Text("Tint color")
        }

        Picker(selection: Binding(
          get: { store.colorScheme },
          set: { store.send(.set(\.colorScheme, $0), transaction: $1) }
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
            .tint(store.tintColor)
          }
        } label: {
          Text("Color scheme")
        }

        Button(role: .destructive) {
          store.send(.reset)
        } label: {
          Text("Reset")
        }
      } header: {
        Text("App theme")
      }
    }
  }
}

#Preview {
  let store = Store(initialState: SettingsReducer.State()) {
    SettingsReducer()
  }

  return SettingsView(store: store)
    .appTheme(store.scope(state: \.theme, action: \.theme))
}
