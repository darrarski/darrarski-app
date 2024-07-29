import CustomDump
import Dependencies
import DependenciesMacros
import XCTest
@testable import Mastodon

// NB: This is a basic test of Macro expansion. More versatile tests are included in `MastodonMacrosPluginTests` target.
final class EndpointMacroTests: XCTestCase {
  func testMacroExpansion() async throws {
    let didSend = LockIsolated<[TestEndpoint.Request]>([])
    let responseStub = ["hello", "world"]
    let testEndpoint = TestEndpoint { request in
      didSend.withValue { $0.append(request) }
      return ["hello", "world"]
    }
    // NB: This will not compile if the macro expansion fails.
    let response = try await testEndpoint(paramA: 7, paramB: "abc")
    expectNoDifference(response, responseStub)
    expectNoDifference(didSend.value, [
      TestEndpoint.Request(
        paramA: 7,
        paramB: "abc"
      )
    ])
  }
}

@Endpoint
private struct TestEndpoint: Sendable {
  struct Request: Equatable, Sendable {
    public init(paramA: Int, paramB: String, paramC: String = "default") {
      self.paramA = paramA
      self.paramB = paramB
      self.paramC = paramC
    }

    var paramA: Int
    var paramB: String
    var paramC: String
  }

  typealias Response = [String]
}
