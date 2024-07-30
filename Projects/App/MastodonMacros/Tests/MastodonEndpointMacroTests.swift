import MacroTesting
import XCTest
@testable import MastodonMacros

final class MastodonEndpointMacroTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      //record: true,
      macros: [MastodonEndpointMacro.self]
    ) {
      super.invokeTest()
    }
  }

  func testExpansion() {
    assertMacro {
      """
      @MastodonEndpoint
      struct GetUser {
        struct Request {
          init(id: Int, name: String? = nil) {
            self.id = id
            self.name = name
          }

          var id: Int
          var name: String?
        }
        struct Response {
          var username: String
        }
      }
      """
    } expansion: {
      """
      struct GetUser {
        struct Request {
          init(id: Int, name: String? = nil) {
            self.id = id
            self.name = name
          }

          var id: Int
          var name: String?
        }
        struct Response {
          var username: String
        }

        @DependencyEndpoint
        public var send: @Sendable (Request) async throws -> Response

        public func callAsFunction(id: Int, name: String? = nil) async throws -> Response {
          try await send(Request(id: id, name: name))
        }
      }

      extension GetUser: Mastodon.Endpoint {
      }
      """
    }
  }

  func testExpansionWhenProtocolAlreadyApplied() {
    assertMacro {
      """
      @MastodonEndpoint
      struct GetUser: Endpoint {
        struct Request {
          init() {}
        }
        struct Response {}
      }
      """
    } expansion: {
      """
      struct GetUser: Endpoint {
        struct Request {
          init() {}
        }
        struct Response {}

        @DependencyEndpoint
        public var send: @Sendable (Request) async throws -> Response

        public func callAsFunction() async throws -> Response {
          try await send(Request())
        }
      }
      """
    }
  }

  func testApplyOnNonStructDiagnostics() {
    assertMacro {
      """
      @MastodonEndpoint
      class GetUser {}
      """
    } diagnostics: {
      """
      @MastodonEndpoint
      ┬────────────────
      ╰─ 🛑 @MastodonEndpoint macro can only be applied on structs.
      class GetUser {}
      """
    }
  }

  func testRequestNonStructDiagnostics() {
    assertMacro {
      """
      @MastodonEndpoint
      struct GetUser {
        class Request {}
      }
      """
    } diagnostics: {
      """
      @MastodonEndpoint
      ┬────────────────
      ╰─ 🛑 @MastodonEndpoint macro requires that GetUser.Request is a struct.
      struct GetUser {
        class Request {}
      }
      """
    }
  }

  func testMissingRequestInitializerDiagnostics() {
    assertMacro {
      """
      @MastodonEndpoint
      struct GetUser {
        struct Request {
          var id: Int
          var name: String?
        }
        struct Response {
          var username: String
        }
      }
      """
    } diagnostics: {
      """
      @MastodonEndpoint
      ┬────────────────
      ╰─ 🛑 @MastodonEndpoint macro requires that GetUser.Request has explicite initializer defined.
      struct GetUser {
        struct Request {
          var id: Int
          var name: String?
        }
        struct Response {
          var username: String
        }
      }
      """
    }
  }
}
