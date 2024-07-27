@attached(member, names: named(send), named(callAsFunction))
@attached(extension, conformances: Endpoint)
macro Endpoint() = #externalMacro(
  module: "MastodonMacrosPlugin",
  type: "EndpointMacro"
)
