protocol Endpoint {
  associatedtype Request
  associatedtype Response
  init()
  var send: @Sendable (Request) async throws -> Response { get set }
}
