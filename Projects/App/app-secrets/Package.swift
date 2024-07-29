// swift-tools-version: 5.10
import PackageDescription

let package = Package(
  name: "app-secrets",
  platforms: [
    .macOS(.v14),
    .iOS(.v17),
  ],
  products: [
    .library(name: "AppSecrets", targets: ["AppSecrets"]),
  ],
  targets: [
    .target(
      name: "AppSecrets",
      resources: [
        .embedInCode("Secrets"),
      ]
    ),
  ]
)
