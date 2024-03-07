// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "app-icon",
  platforms: [
    .macOS(.v13),
  ],
  products: [
    .executable(name: "app-icon-export", targets: ["app-icon-export"]),
    .library(name: "AppIcon", targets: ["AppIcon"]),
  ],
  dependencies: [
    .package(url: "https://github.com/darrarski/swiftui-app-icon-creator.git", from: "1.2.0"),
  ],
  targets: [
    .executableTarget(
      name: "app-icon-export",
      dependencies: [
        .target(name: "AppIcon"),
      ]
    ),
    .target(
      name: "AppIcon",
      dependencies: [
        .product(name: "AppIconCreator", package: "swiftui-app-icon-creator"),
      ]
    ),
  ]
)
