// swift-tools-version: 5.10
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
    .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.10.0"),
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
