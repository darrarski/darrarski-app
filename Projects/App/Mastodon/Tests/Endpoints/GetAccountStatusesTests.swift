import CustomDump
import Dependencies
import InlineSnapshotTesting
import SnapshotTesting
import XCTest
@testable import Mastodon

final class GetAccountStatusesTests: XCTestCase {
  func testRequest() async throws {
    let urlRequests = LockIsolated<[URLRequest]>([])
    let responseStub = GetAccountStatuses.Response.preview
    let response = try await withDependencies {
      $0.httpClient.dataForRequest = { urlRequest in
        urlRequests.withValue { $0.append(urlRequest) }
        return (
          GetAccountStatuses.Response.previewJSON,
          HTTPURLResponse.stub(200)
        )
      }
    } operation: {
      try await GetAccountStatuses.live(
        accountId: "account id",
        limit: 1337,
        excludeReplies: true
      )
    }

    XCTAssertEqual(urlRequests.value.count, 1)
    if let urlRequest = urlRequests.first {
      assertInlineSnapshot(of: urlRequest, as: .raw) {
          """
          GET https://mastodon.social/api/v1/accounts/account%20id/statuses?exclude_replies=true&limit=1337
          """
      }
    }
    expectNoDifference(response, responseStub)
  }

  func testErrorResponse() async throws {
    do {
      try await withDependencies {
        $0.httpClient.dataForRequest = { urlRequest in
          return (
            "server error".data(using: .utf8)!,
            HTTPURLResponse.stub(500)
          )
        }
      } operation: {
        try await GetAccountStatuses.live(accountId: "")
      }
      XCTFail("Expected to throw, but didn't")
    } catch {
      expectNoDifference(
        error as? ErrorResponse,
        ErrorResponse(
          statusCode: 500,
          data: "server error".data(using: .utf8)!
        )
      )
    }
  }
}
