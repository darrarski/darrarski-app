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
      resources: [
        // TODO: Store TelemetryDeckAppID securely.
        // Store in a dedicated swift package?
        // In swift package we can add embedded-in-code resource to improve security a bit:
        // .embedInCode("Secrets/TelemetryDeckAppID"),
      ],
      dependencies: [
        .target(name: "AppShared"),
        .target(name: "ContactFeature"),
        .target(name: "FeedFeature"),
        .target(name: "ProjectsFeature"),
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
    .macro(
      name: "MastodonMacrosPlugin",
      deploymentTarget: "14.0",
      dependencies: [
        .external(name: "SwiftSyntaxMacros"),
        .external(name: "SwiftCompilerPlugin"),
      ],
      testTarget: false, // TODO: Fix tests for MastodonMacrosPlugin
      testDependencies: [
        .external(name: "MacroTesting"),
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
  ]
)
