// swift-tools-version: 5.10
import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
  productTypes: [
    "AsyncAlgorithms": .framework,
    "CombineSchedulers": .framework,
    "ComposableArchitecture": .framework,
    "ConcurrencyExtras": .framework,
    "Dependencies": .framework,
    "IdentifiedCollections": .framework,
    "InternalCollectionsUtilities": .framework,
    "IssueReporting": .framework,
    "Kingfisher": .framework,
    "OrderedCollections": .framework,
    "XCTestDynamicOverlay": .framework,
  ],
  targetSettings: [
    // NB: This fixes "XCTest not found" issues:
    "SwiftSyntaxMacrosTestSupport": SettingsDictionary()
      .merging(["ENABLE_TESTING_SEARCH_PATHS": true]),
    "_SwiftSyntaxTestSupport": SettingsDictionary()
      .merging(["ENABLE_TESTING_SEARCH_PATHS": true]),
  ]
)
#endif

let package = Package(
  name: "",
  dependencies: [
    .package(url: "https://github.com/ActuallyTaylor/SwiftHTMLToMarkdown.git", from: "1.1.1"),
    .package(url: "https://github.com/apple/swift-syntax.git", from: "510.0.2"),
    .package(url: "https://github.com/darrarski/swiftui-app-icon-creator.git", from: "1.2.0"),
    .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.12.0"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.5.1"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.2"),
    .package(url: "https://github.com/swiftcsv/SwiftCSV.git", from: "0.10.0"),
    .package(url: "https://github.com/TelemetryDeck/SwiftClient.git", from: "1.5.1"),
  ]
)
