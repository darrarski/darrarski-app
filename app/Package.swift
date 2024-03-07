// swift-tools-version: 5.10
import CompilerPluginSupport
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
  ],
  dependencies: [
    .package(url: "https://github.com/ActuallyTaylor/SwiftHTMLToMarkdown.git", from: "1.1.1"),
    .package(url: "https://github.com/TelemetryDeck/SwiftClient.git", from: "1.5.0"),
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.7.1"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.15.2"),
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
        .target(name: "MastodonMacros"),
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
        .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ]
    ),
    .macro(
      name: "MastodonMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .testTarget(
      name: "MastodonMacrosTests",
      dependencies: [
        .target(name: "MastodonMacros"),
        .product(name: "MacroTesting", package: "swift-macro-testing"),
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
