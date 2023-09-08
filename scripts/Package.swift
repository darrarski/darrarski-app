// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "scripts",
  platforms: [
    .macOS(.v14),
  ],
  products: [
    .executable(name: "projects-csv2json", targets: ["projects-csv2json"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.8.1"),
  ],
  targets: [
    .executableTarget(
      name: "projects-csv2json",
      dependencies: [
        .product(name: "SwiftCSV", package: "SwiftCSV"),
      ]
    ),
  ]
)
