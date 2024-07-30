import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
  let providingMacros: [any Macro.Type] = [
    MastodonEndpointMacro.self,
  ]
}
