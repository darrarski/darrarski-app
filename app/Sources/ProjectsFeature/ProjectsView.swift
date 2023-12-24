import AppShared
import ComposableArchitecture
import OrderedCollections
import SwiftUI

@ViewAction(for: ProjectsReducer.self)
public struct ProjectsView: View {
  enum AnimationValue: Equatable {
    case info(ProjectsInfo?, Bool)
    case groups(IdentifiedArrayOf<ProjectsGroup>, Bool)
  }

  public init(store: StoreOf<ProjectsReducer>) {
    self.store = store
  }

  public let store: StoreOf<ProjectsReducer>
  @State var isRefreshing = false
  var placeholderScale: CGFloat = 0.9
  var showInfoPlaceholder: Bool { store.info == nil && store.isLoading }
  var showGroupsPlaceholder: Bool { store.projects.isEmpty && store.isLoading }
  var infoAnimationValue: AnimationValue { .info(store.info, showInfoPlaceholder) }
  var groupsAnimationValue: AnimationValue { .groups(store.groups, showGroupsPlaceholder) }

  public var body: some View {
    ScrollView {
      VStack {
        ZStack {
          if showInfoPlaceholder {
            infoView(.preview)
              .disabled(true)
              .scaleEffect(x: placeholderScale, y: placeholderScale, anchor: .center)
              .transition(.opacity)
          } else if let info = store.info {
            infoView(info)
              .transition(
                .scale(scale: placeholderScale, anchor: .center)
                .combined(with: .opacity)
              )
          }
        }
        .redacted(reason: showInfoPlaceholder ? .placeholder : [])
        .animation(.bouncy, value: infoAnimationValue)

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
          if showGroupsPlaceholder {
            groupsView(.placeholder)
              .disabled(true)
              .scaleEffect(x: placeholderScale, y: placeholderScale, anchor: .center)
              .transition(.opacity)
          } else {
            groupsView(store.groups)
              .transition(
                .scale(scale: placeholderScale, anchor: .center)
                .combined(with: .opacity)
              )
          }
        }
        .redacted(reason: showGroupsPlaceholder ? .placeholder : [])
        .animation(.bouncy, value: groupsAnimationValue)
      }
      .frame(maxWidth: .infinity)
      .padding()
    }
    .task {
      await send(.task).finish()
    }
    .refreshTask {
      isRefreshing = true
      defer { isRefreshing = false }
      await send(.refreshTask).finish()
    }
    .navigationTitle("Projects")
    .toolbar {
#if os(macOS)
      ToolbarItem(placement: .primaryAction) {
        Button {
          send(.refreshButtonTapped)
        } label: {
          Text("Refresh")
        }
        .disabled(store.isLoading)
      }
#elseif os(iOS)
      ToolbarItem {
        if !isRefreshing, store.isLoading {
          ProgressView()
        }
      }
#endif
    }
  }

  func infoView(_ info: ProjectsInfo) -> some View {
    Text(info.content)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  func groupsView(_ groups: IdentifiedArrayOf<ProjectsGroup>) -> some View {
    ForEach(groups) { group in
      Section {
        ForEach(group.projects) { project in
          Button {
            send(.projectCardTapped(project.id))
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
        .foregroundStyle(.green)
        .opacity(0.03)
        .saturation(3)
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

private extension IdentifiedArrayOf<ProjectsGroup> {
  static let placeholder = IdentifiedArrayOf<ProjectsGroup>(
    groupingByYear: IdentifiedArrayOf<Project>(
      uniqueElements: [Project].preview
        .sorted { $0.date > $1.date }
        .prefix(3)
        .enumerated()
        .map(makeUpdate { $0.element.name.append("\($0.offset)") })
        .map(\.element)
    )
  )
}

#Preview {
  NavigationStack {
    ProjectsView(store: Store(initialState: ProjectsReducer.State()) {
      ProjectsReducer()
    })
  }
  .appTheme(.default)
}
