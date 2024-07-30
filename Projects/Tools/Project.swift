import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
  name: "Tools",
  version: ("1.0.0", build: 0),
  targets: [
    .commandLineTool(
      name: "ProjectsCSV2JSON",
      deploymentTarget: "14.0",
      dependencies: [
        .external(name: "SwiftCSV"),
      ]
    ),
  ]
)
