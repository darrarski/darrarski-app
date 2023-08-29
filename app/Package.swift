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
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
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
