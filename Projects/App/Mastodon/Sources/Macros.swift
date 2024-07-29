@attached(member, names: named(send), named(callAsFunction))
@attached(extension, conformances: Endpoint)
public macro MastodonEndpoint() = #externalMacro(
  module: "MastodonMacrosPlugin",
  type: "MastodonEndpointMacro"
)
