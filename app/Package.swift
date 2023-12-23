// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "app",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "AppShared", targets: ["AppShared"]),
    .library(name: "ContactFeature", targets: ["ContactFeature"]),
    .library(name: "FeedFeature", targets: ["FeedFeature"]),
    .library(name: "Mastodon", targets: ["Mastodon"]),
    .library(name: "ProjectsFeature", targets: ["ProjectsFeature"]),
    .library(name: "SettingsFeature", targets: ["SettingsFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/ActuallyTaylor/SwiftHTMLToMarkdown.git", from: "1.1.1"),
    .package(url: "https://github.com/TelemetryDeck/SwiftClient.git", from: "1.5.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "observation-beta"),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .target(name: "AppShared"),
        .target(name: "ContactFeature"),
        .target(name: "FeedFeature"),
        .target(name: "ProjectsFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "TelemetryClient", package: "SwiftClient"),
      ],
      resources: [
        .embedInCode("Secrets/TelemetryDeckAppID"),
      ]
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        .target(name: "AppFeature"),
      ]
    ),
    .target(
      name: "AppShared",
      dependencies: [
        .target(name: "Mastodon"),
        .product(name: "SwiftHTMLtoMarkdown", package: "SwiftHTMLToMarkdown"),
      ],
      resources: [
        .process("Resources/Media.xcassets"),
      ]
    ),
    .testTarget(
      name: "AppSharedTests",
      dependencies: [
        .target(name: "AppShared"),
      ]
    ),
    .target(
      name: "ContactFeature",
      dependencies: [
        .target(name: "AppShared"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Kingfisher", package: "Kingfisher"),
      ],
      resources: [
        .copy("Resources/contact_preview.json"),
      ]
    ),
    .testTarget(
      name: "ContactFeatureTests",
      dependencies: [
        .target(name: "ContactFeature"),
      ]
    ),
    .target(
      name: "FeedFeature",
      dependencies: [
        .target(name: "AppShared"),
        .target(name: "Mastodon"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Kingfisher", package: "Kingfisher"),
      ]
    ),
    .testTarget(
      name: "FeedFeatureTests",
      dependencies: [
        .target(name: "FeedFeature"),
      ]
    ),
    .target(
      name: "Mastodon",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      resources: [
        .copy("Resources/statuses_preview.json"),
      ]
    ),
    .testTarget(
      name: "MastodonTests",
      dependencies: [
        .target(name: "Mastodon"),
      ]
    ),
    .target(
      name: "ProjectsFeature",
      dependencies: [
        .target(name: "AppShared"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      resources: [
        .copy("Resources/projects_preview.json"),
        .copy("Resources/projects_preview.md"),
      ]
    ),
    .testTarget(
      name: "ProjectsFeatureTests",
      dependencies: [
        .target(name: "ProjectsFeature"),
      ]
    ),
    .target(
      name: "SettingsFeature",
      dependencies: [
        .target(name: "AppShared"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "SettingsFeatureTests",
      dependencies: [
        .target(name: "SettingsFeature"),
      ]
    ),
  ]
)

for target in package.targets {
  if [.binary, .system].contains(target.type) { continue }
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?.append(
    .unsafeFlags([
      //"-Xfrontend", "-strict-concurrency=targeted",
      "-Xfrontend", "-strict-concurrency=complete",
      "-Xfrontend", "-enable-actor-data-race-checks",
      //"-Xfrontend", "-debug-time-function-bodies",
      //"-Xfrontend", "-debug-time-expression-type-checking",
      //"-enable-library-evolution",
    ], .when(configuration: .debug))
  )
}
