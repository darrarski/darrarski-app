import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "App",
  version: ("1.0.0", build: 0),
  targets: [
    .app(
      name: "DarrarskiApp",
      appName: "DR",
      dependencies: [
        .target(name: "AppFeature"),
      ]
    ),
    .framework(
      name: "AppFeature",
      dependencies: [
        .target(name: "AppShared"),
        .target(name: "ContactFeature"),
        .target(name: "FeedFeature"),
        .target(name: "ProjectsFeature"),
        .package(product: "AppSecrets"),
        .external(name: "ComposableArchitecture"),
        .external(name: "TelemetryClient"),
      ]
    ),
    .framework(
      name: "AppShared",
      resources: [
        "AppShared/Resources/**",
      ],
      dependencies: [
        .target(name: "Mastodon"),
        .external(name: "SwiftHTMLtoMarkdown"),
      ]
    ),
    .framework(
      name: "ContactFeature",
      resources: [
        "ContactFeature/Resources/**",
      ],
      dependencies: [
        .target(name: "AppShared"),
        .external(name: "ComposableArchitecture"),
        .external(name: "Kingfisher"),
      ]
    ),
    .framework(
      name: "FeedFeature",
      dependencies: [
        .target(name: "AppShared"),
        .target(name: "Mastodon"),
        .external(name: "ComposableArchitecture"),
        .external(name: "Kingfisher"),
      ]
    ),
    .framework(
      name: "Mastodon",
      resources: [
        "Mastodon/Resources/**",
      ],
      dependencies: [
        .target(name: "MastodonMacrosPlugin"),
        .external(name: "ComposableArchitecture"),
      ],
      settings: {
        $0.base.merge(.enableUserScriptSandboxing(false))
      },
      testDependencies: [
        .external(name: "InlineSnapshotTesting"),
        .external(name: "SnapshotTesting"),
      ]
    ),
    .framework(
      name: "MastodonMacros",
      destinations: .macOS,
      deploymentTargets: .macOS("14.0"),
      dynamic: false,
      dependencies: [
        .external(name: "SwiftSyntaxMacros"),
        .external(name: "SwiftCompilerPlugin"),
      ],
      testDependencies: [
        .external(name: "MacroTesting"),
      ]
    ),
    .macros(
      name: "MastodonMacrosPlugin",
      deploymentTarget: "14.0",
      dependencies: [
        .target(name: "MastodonMacros"),
      ]
    ),
    .framework(
      name: "ProjectsFeature",
      resources: [
        "ProjectsFeature/Resources/**",
      ],
      dependencies: [
        .target(name: "AppShared"),
        .external(name: "ComposableArchitecture"),
      ]
    ),
  ],
  packages: [
    .local(path: .relativeToManifest("app-secrets")),
  ]
)
