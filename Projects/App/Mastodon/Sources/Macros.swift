@attached(member, names: named(send), named(callAsFunction))
@attached(extension, conformances: Endpoint)
macro MastodonEndpoint() = #externalMacro(
  module: "MastodonMacrosPlugin",
  type: "MastodonEndpointMacro"
)
