import ProjectDescription

extension Settings {
  public func customized(with customize: (inout Settings) -> Void) -> Settings {
    var copy = self
    customize(&copy)
    return copy
  }
}

extension SettingsDictionary {
  public static func enableUserScriptSandboxing(_ enable: Bool = true) -> SettingsDictionary {
    ["ENABLE_USER_SCRIPT_SANDBOXING": .init(booleanLiteral: enable)]
  }
}

public enum OtherSwiftFlags {
  static var enableActorDataRaceChecks: String {
    "-Xfrontend -enable-actor-data-race-checks"
  }

  static var debugTime: String {
    "-Xfrontend -debug-time-function-bodies -Xfrontend -debug-time-expression-type-checking"
  }

  static var upcomingFeatures: String {
    var components: [String] = []
    let enableUpcomingFeature = "-enable-upcoming-feature"
    let enableExperimentalFeature = "-enable-experimental-feature"
#if !hasFeature(ConciseMagicFile)
    components.append(contentsOf: [enableUpcomingFeature, "ConciseMagicFile"])
#endif
#if !hasFeature(ForwardTrailingClosures)
    components.append(contentsOf: [enableUpcomingFeature, "ForwardTrailingClosures"])
#endif
#if !hasFeature(StrictConcurrency)
    components.append(contentsOf: [enableUpcomingFeature, "StrictConcurrency"])
    components.append(contentsOf: [enableExperimentalFeature, "StrictConcurrency"])
#endif
#if !hasFeature(BareSlashRegexLiterals)
    components.append(contentsOf: [enableUpcomingFeature, "BareSlashRegexLiterals"])
#endif
#if !hasFeature(ImplicitOpenExistentials)
    components.append(contentsOf: [enableUpcomingFeature, "ImplicitOpenExistentials"])
#endif
#if !hasFeature(ImportObjcForwardDeclarations)
    components.append(contentsOf: [enableUpcomingFeature, "ImportObjcForwardDeclarations"])
#endif
#if !hasFeature(DisableOutwardActorInference)
    components.append(contentsOf: [enableUpcomingFeature, "DisableOutwardActorInference"])
#endif
#if !hasFeature(InternalImportsByDefault)
    components.append(contentsOf: [enableUpcomingFeature, "InternalImportsByDefault"])
#endif
#if !hasFeature(IsolatedDefaultValues)
    components.append(contentsOf: [enableUpcomingFeature, "IsolatedDefaultValues"])
#endif
#if !hasFeature(GlobalConcurrency)
    components.append(contentsOf: [enableUpcomingFeature, "GlobalConcurrency"])
#endif
#if !hasFeature(ExistentialAny)
    components.append(contentsOf: [enableUpcomingFeature, "ExistentialAny"])
#endif
    return components.joined(separator: " ")
  }
}
