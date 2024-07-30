import MastodonMacros
import SwiftSyntax
import SwiftSyntaxMacros

enum MastodonEndpointMacro {}

extension MastodonEndpointMacro: ExtensionMacro {
  static func expansion(of node: AttributeSyntax, attachedTo declaration: some DeclGroupSyntax, providingExtensionsOf type: some TypeSyntaxProtocol, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [ExtensionDeclSyntax] {
    try MastodonMacros.MastodonEndpointMacro.expansion(of: node, attachedTo: declaration, providingExtensionsOf: type, conformingTo: protocols, in: context)
  }
}

extension MastodonEndpointMacro: MemberMacro {
  static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
    try MastodonMacros.MastodonEndpointMacro.expansion(of: node, providingMembersOf: declaration, in: context)
  }
}
