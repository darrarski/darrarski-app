import ProjectDescription

extension Target {
  public static let defaultDestinations: Destinations = [.iPhone, .iPad, .mac]
  public static let defaultDeploymentTargets: DeploymentTargets = .multiplatform(
    iOS: "17.0",
    macOS: "14.0"
  )
  static let bundleIdPrefix = "pl.darrarski"
  static let devTeam = "P38XW29864"
  static let defaultSettings = DefaultSettings.recommended(
    excluding: [
      "CURRENT_PROJECT_VERSION",
      "MARKETING_VERSION",
      "VERSION_INFO_PREFIX",
      "VERSIONING_SYSTEM",
    ]
  )
  static let infoPlistDefaults: [String: Plist.Value] = [
    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
  ]
}

extension [Target] {
  public static func app(
    name: String,
    appName: String,
    destinations: Destinations = Target.defaultDestinations,
    deploymentTargets: DeploymentTargets = Target.defaultDeploymentTargets,
    dependencies: [TargetDependency] = [],
    settings customizeSettings: (inout Settings) -> Void = { _ in }
  ) -> [Target] {
    [
      .target(
        name: name,
        destinations: destinations,
        product: .app,
        productName: name, // NB: Makes the scheme name equal to target name
        bundleId: "\(Target.bundleIdPrefix).\(name)",
        deploymentTargets: deploymentTargets,
        infoPlist: .file(path: "\(name)/Info.plist"),
        sources: ["\(name)/Sources/**"],
        resources: ["\(name)/Resources/**"],
        entitlements: .file(path: "\(name)/\(name).entitlements"),
        dependencies: dependencies,
        settings: .settings(
          base: SettingsDictionary()
            .otherSwiftFlags(["$(inherited)"])
            .automaticCodeSigning(devTeam: Target.devTeam)
            .merging([
              "GENERATE_INFOPLIST_FILE": "NO",
              "PRODUCT_MODULE_NAME": "$(TARGET_NAME:c99extidentifier)",
              "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
              "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
              "ENABLE_MODULE_VERIFIER": "YES",
              "MODULE_VERIFIER_SUPPORTED_LANGUAGE_STANDARDS": "gnu11 gnu++14",
              "PRODUCT_NAME": .string(appName), // NB: Makes the app name "\(appName).app"
            ]),
          defaultSettings: Target.defaultSettings
        ).customized(with: customizeSettings)
      ),
    ]
  }
}

extension [Target] {
  public static func framework(
    name: String,
    destinations: Destinations = Target.defaultDestinations,
    deploymentTargets: DeploymentTargets = Target.defaultDeploymentTargets,
    dynamic: Bool = true,
    resources: ResourceFileElements? = nil,
    dependencies: [TargetDependency] = [],
    settings customizeSettings: (inout Settings) -> Void = { _ in },
    testTarget: Bool = true,
    testResources: ResourceFileElements? = nil,
    testDependencies: [TargetDependency] = [],
    testSettings customizeTestSettings: (inout Settings) -> Void = { _ in }
  ) -> [Target] {
    var targets: [Target] = [
      .target(
        name: name,
        destinations: destinations,
        product: dynamic ? .framework : .staticFramework,
        bundleId: "\(Target.bundleIdPrefix).\(name)",
        deploymentTargets: deploymentTargets,
        infoPlist: .extendingDefault(with: Target.infoPlistDefaults),
        sources: ["\(name)/Sources/**"],
        resources: resources,
        dependencies: dependencies,
        settings: .settings(
          base: SettingsDictionary()
            .otherSwiftFlags(["$(inherited)"]),
          defaultSettings: Target.defaultSettings
        ).customized(with: customizeSettings)
      ),
    ]
    if testTarget {
      targets.append(.target(
        name: "\(name)Tests",
        destinations: destinations,
        product: .unitTests,
        bundleId: "\(Target.bundleIdPrefix).\(name)Tests",
        deploymentTargets: deploymentTargets,
        infoPlist: .extendingDefault(with: Target.infoPlistDefaults),
        sources: ["\(name)/Tests/**"],
        resources: testResources,
        dependencies: [.target(name: name)] + testDependencies,
        settings: .settings(
          base: SettingsDictionary()
            .otherSwiftFlags(["$(inherited)"]),
          defaultSettings: Target.defaultSettings
        ).customized(with: customizeTestSettings)
      ))
    }
    return targets
  }
}

extension [Target] {
  public static func commandLineTool(
    name: String,
    deploymentTarget: String,
    dependencies: [TargetDependency] = [],
    settings customizeSettings: (inout Settings) -> Void = { _ in }
  ) -> [Target] {
    [
      .target(
        name: name,
        destinations: .macOS,
        product: .commandLineTool,
        bundleId: "\(Target.bundleIdPrefix).\(name)",
        deploymentTargets: .macOS(deploymentTarget),
        infoPlist: .extendingDefault(with: Target.infoPlistDefaults),
        sources: ["\(name)/Sources/**"],
        dependencies: dependencies,
        settings: .settings(
          base: SettingsDictionary()
            .otherSwiftFlags(["$(inherited)"]),
          defaultSettings: Target.defaultSettings
        ).customized(with: customizeSettings)
      ),
    ]
  }
}

extension [Target] {
  public static func macros(
    name: String,
    deploymentTarget: String,
    dependencies: [TargetDependency] = [],
    settings customizeSettings: (inout Settings) -> Void = { _ in }
  ) -> [Target] {
    [
      .target(
        name: name,
        destinations: .macOS,
        product: .macro,
        bundleId: "\(Target.bundleIdPrefix).\(name)",
        deploymentTargets: .macOS(deploymentTarget),
        infoPlist: .extendingDefault(with: Target.infoPlistDefaults),
        sources: ["\(name)/Sources/**"],
        dependencies: dependencies,
        settings: .settings(
          base: SettingsDictionary()
            .otherSwiftFlags(["$(inherited)"]),
          defaultSettings: Target.defaultSettings
        ).customized(with: customizeSettings)
      )
    ]
  }
}
