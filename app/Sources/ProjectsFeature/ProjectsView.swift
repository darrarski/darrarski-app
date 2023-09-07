import AppShared
import ComposableArchitecture
import OrderedCollections
import SwiftUI

public struct ProjectsView: View {
  public init(store: StoreOf<ProjectsReducer>) {
    self.store = store
  }

  let store: StoreOf<ProjectsReducer>

  public var body: some View {
    ScrollView {
      WithViewStore(store, observe: \.groups) { viewStore in
        LazyVGrid(
          columns: [
            GridItem(
              .adaptive(minimum: 250, maximum: .infinity),
              spacing: 16,
              alignment: .topLeading
            ),
          ],
          alignment: .leading,
          spacing: 16,
          pinnedViews: [.sectionHeaders]
        ) {
          ForEach(viewStore.state) { group in
            Section {
              ForEach(group.projects) { project in
                Button {
                  viewStore.send(.view(.projectCardTapped(project.id)))
                } label: {
                  projectCardView(project)
                }
                .buttonStyle(.plain)
              }
            } header: {
              groupHeader(group)
            }
          }
        }
      }
      .frame(maxWidth: .infinity)
      .padding()
    }
    .task {
      await store.send(.view(.task)).finish()
    }
    .refreshTask {
      await store.send(.view(.refreshTask)).finish()
    }
    .navigationTitle("Projects")
    .toolbar {
#if os(macOS)
      ToolbarItem(placement: .primaryAction) {
        WithViewStore(store, observe: \.isLoading) { viewStore in
          let isLoading = viewStore.state

          Button {
            store.send(.view(.refreshButtonTapped))
          } label: {
            Text("Refresh")
          }
          .disabled(isLoading)
        }
      }
#endif
    }
  }

  func groupHeader(_ group: ProjectsGroup) -> some View {
    Text(group.date.formatted(Date.FormatStyle().year(.extended())))
      .font(.title)
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .background(.ultraThinMaterial)
      .clipShape(Capsule())
      .padding(.horizontal, 4)
      .padding(.vertical, 4)
  }

  func projectCardView(_ project: Project) -> some View {
    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline) {
        Text(project.name)
          .font(.title2)
          .foregroundStyle(.primary)

        if project.url != nil {
          Spacer()
          Image(systemName: "link")
            .foregroundStyle(.tint)
        }
      }

      Divider()

      Text(project.type)
        .font(.body)
        .foregroundStyle(.secondary)

      tagsView(project.tags)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    .padding()
    .background {
      Rectangle()
        .foregroundStyle(.tint)
        .opacity(0.25)
        .saturation(0.5)
        .visualEffect(verticalScrollPositionHueRotation)
    }
#if os(iOS)
    .background(.thickMaterial)
#elseif os(macOS)
    .background(.background)
#endif
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .overlay {
      RoundedRectangle(cornerRadius: 16)
        .stroke(.primary.opacity(0.1), lineWidth: 1)
    }
  }

  func tagsView(_ tags: [String]) -> some View {
    FlowLayout(spacing: 8) {
      ForEach(OrderedSet(tags), id: \.self) { tag in
        tagView(tag)
      }
    }
  }

  func tagView(_ tag: String) -> some View {
    Text(tag)
      .foregroundStyle(.secondary)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .font(.body)
      .overlay {
        RoundedRectangle(cornerRadius: 4)
          .stroke()
          .foregroundStyle(.tertiary)
      }
  }

  @Sendable
  func verticalScrollPositionHueRotation(
    content: EmptyVisualEffect,
    geometryProxy: GeometryProxy
  ) -> some VisualEffect {
    let scrollHeight = geometryProxy.bounds(of: .scrollView)?.height ?? 100
    let contentLocation = geometryProxy.frame(in: .scrollView).minY
    let scrollProgress = contentLocation / scrollHeight
    return content.hueRotation(.degrees(180 * scrollProgress))
  }
}

#Preview {
  NavigationStack {
    ProjectsView(store: Store(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    })
  }
  .tint(.appTint)
}
