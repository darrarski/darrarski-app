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
    .library(name: "ContactFeature", targets: ["ContactFeature"]),
    .library(name: "FeedFeature", targets: ["FeedFeature"]),
    .library(name: "ProjectsFeature", targets: ["ProjectsFeature"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .target(name: "ContactFeature"),
        .target(name: "FeedFeature"),
        .target(name: "ProjectsFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        .target(name: "AppFeature"),
      ]
    ),
    .target(
      name: "ContactFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "FeedFeatureTests",
      dependencies: [
        .target(name: "FeedFeature"),
      ]
    ),
    .target(
      name: "ProjectsFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
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
