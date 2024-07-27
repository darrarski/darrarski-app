import ProjectDescription

extension Project {
  public init(
    name: String,
    version: (marketing: String, build: Int),
    targets: [[Target]],
    settings customizeSettings: (inout Settings) -> Void = { _ in }
  ) {
    self.init(
      name: name,
      options: .options(
        automaticSchemesOptions: .enabled(
          targetSchemesGrouping: .byNameSuffix(
            build: [],
            test: ["Tests"],
            run: []
          ),
          codeCoverageEnabled: true,
          testingOptions: [.parallelizable, .randomExecutionOrdering]
        ),
        disableSynthesizedResourceAccessors: true,
        textSettings: .textSettings(
          usesTabs: false,
          indentWidth: 2,
          wrapsLines: false
        )
      ),
      settings: .settings(
        base: SettingsDictionary()
          .currentProjectVersion("\(version.build)")
          .marketingVersion(version.marketing)
          .appleGenericVersioningSystem()
          .otherSwiftFlags([
            "$(inherited)",
            OtherSwiftFlags.upcomingFeatures,
          ])
          .merging(.enableUserScriptSandboxing()),
        configurations: [
          .debug(
            name: .debug,
            settings: SettingsDictionary()
              .otherSwiftFlags([
                "$(inherited)",
                OtherSwiftFlags.enableActorDataRaceChecks,
                OtherSwiftFlags.debugTime,
              ])
          ),
          .release(
            name: .release
          ),
        ]
      ).customized(with: customizeSettings),
      targets: targets.flatMap { $0 }
    )
  }
}
