import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum EndpointMacro {}

extension EndpointMacro: ExtensionMacro {
  static func expansion(
    of node: SwiftSyntax.AttributeSyntax,
    attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
    providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
    conformingTo protocols: [SwiftSyntax.TypeSyntax],
    in context: some SwiftSyntaxMacros.MacroExpansionContext
  ) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
    if let inheritanceClause = declaration.inheritanceClause,
       inheritanceClause.inheritedTypes.contains(where: {
         ["Endpoint"].withQualified.contains($0.type.trimmedDescription)
       })
    {
      return []
    }
    let ext: DeclSyntax = "extension \(type.trimmed): Mastodon.Endpoint {}"
    return [ext.cast(ExtensionDeclSyntax.self)]
  }
}

extension EndpointMacro: MemberMacro {
  static func expansion<
    Declaration: DeclGroupSyntax,
    Context: MacroExpansionContext
  >(
    of node: AttributeSyntax,
    providingMembersOf declaration: Declaration,
    in context: Context
  ) throws -> [DeclSyntax] {
    var macroName: String { node.attributeName.trimmedDescription }

    guard let endpointStruct: StructDeclSyntax = declaration.as(StructDeclSyntax.self)
    else {
      throw MacroError(
        "@\(macroName) macro can only be applied on structs."
      )
    }

    var endpointName: String { endpointStruct.name.trimmedDescription }

    guard let requestStruct: StructDeclSyntax = endpointStruct.memberBlock.members
      .first(where: { $0.decl.as(StructDeclSyntax.self)?.name.text == "Request" })?
      .decl.as(StructDeclSyntax.self)
    else {
      throw MacroError(
        "@\(macroName) macro requires that \(endpointName).Request is a struct."
      )
    }

    guard let requestInitializer: InitializerDeclSyntax = requestStruct
      .memberBlock.members
      .compactMap({ $0.decl.as(InitializerDeclSyntax.self) })
      .first
    else {
      throw MacroError(
        "@\(macroName) macro requires that \(endpointName).Request has explicite initializer defined."
      )
    }

    let requestInitializerSignature: String = requestInitializer
      .signature.trimmedDescription

    let requestInitializerParameters: String = requestInitializer
      .signature.parameterClause.parameters
      .map { $0.firstName.text }
      .map { "\($0): \($0)" }
      .joined(separator: ", ")

    return [
      """
      @DependencyEndpoint
      public var send: @Sendable (Request) async throws -> Response
      """,
      """
      public func callAsFunction\(raw: requestInitializerSignature) async throws -> Response {
        try await send(Request(\(raw: requestInitializerParameters)))
      }
      """
    ]
  }
}

private extension Array where Element == String {
  var withQualified: Self { flatMap { [$0, "Mastodon.\($0)"] } }
}
