import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "AppIcon",
  version: ("1.0.0", build: 0),
  targets: [
    .framework(
      name: "AppIcon",
      destinations: .macOS,
      deploymentTargets: .macOS("14.0"),
      dependencies: [
        .external(name: "AppIconCreator"),
      ],
      testTarget: false
    ),
    .commandLineTool(
      name: "AppIconExport",
      deploymentTarget: "14.0",
      dependencies: [
        .target(name: "AppIcon"),
      ]
    ),
  ]
)
