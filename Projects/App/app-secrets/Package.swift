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

for target in package.targets where target.type == .regular {
  var swiftSettings = target.swiftSettings ?? []
  swiftSettings.append(.unsafeFlags([
    "-Xfrontend", "-enable-actor-data-race-checks",
    "-Xfrontend", "-debug-time-function-bodies",
    "-Xfrontend", "-debug-time-expression-type-checking"
  ], .when(configuration: .debug)))
#if !hasFeature(ConciseMagicFile)
  swiftSettings.append(.enableUpcomingFeature("ConciseMagicFile"))
#endif
#if !hasFeature(ForwardTrailingClosures)
  swiftSettings.append(.enableUpcomingFeature("ForwardTrailingClosures"))
#endif
#if !hasFeature(StrictConcurrency)
  swiftSettings.append(.enableUpcomingFeature("StrictConcurrency"))
  swiftSettings.append(.enableExperimentalFeature("StrictConcurrency"))
#endif
#if !hasFeature(BareSlashRegexLiterals)
  swiftSettings.append(.enableUpcomingFeature("BareSlashRegexLiterals"))
#endif
#if !hasFeature(ImplicitOpenExistentials)
  swiftSettings.append(.enableUpcomingFeature("ImplicitOpenExistentials"))
#endif
#if !hasFeature(ImportObjcForwardDeclarations)
  swiftSettings.append(.enableUpcomingFeature("ImportObjcForwardDeclarations"))
#endif
#if !hasFeature(DisableOutwardActorInference)
  swiftSettings.append(.enableUpcomingFeature("DisableOutwardActorInference"))
#endif
#if !hasFeature(IsolatedDefaultValues)
  swiftSettings.append(.enableUpcomingFeature("IsolatedDefaultValues"))
#endif
#if !hasFeature(GlobalConcurrency)
  swiftSettings.append(.enableUpcomingFeature("GlobalConcurrency"))
#endif
#if !hasFeature(ExistentialAny)
  swiftSettings.append(.enableUpcomingFeature("ExistentialAny"))
#endif
  target.swiftSettings = swiftSettings
}

