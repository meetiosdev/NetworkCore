import Foundation
import XCTest
@testable import NetworkCore

final class PolicyAndAuthTests: XCTestCase {
    func testAuthInterceptorSkipsPublicEndpoint() async throws {
        let store = TokenStore()
        await store.save(AuthTokens(accessToken: "secret"))
        let interceptor = AuthInterceptor(tokenStore: store)
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://api.example.com/public")))

        let adapted = try await interceptor.adapt(request, endpoint: PublicEndpoint())

        XCTAssertNil(adapted.value(forHTTPHeaderField: "Authorization"))
    }

    func testAuthInterceptorAddsBearerForPrivateEndpoint() async throws {
        let store = TokenStore()
        await store.save(AuthTokens(accessToken: "secret"))
        let interceptor = AuthInterceptor(tokenStore: store)
        let request = URLRequest(url: try XCTUnwrap(URL(string: "https://api.example.com/private")))

        let adapted = try await interceptor.adapt(request, endpoint: PrivateEndpoint())

        XCTAssertEqual(adapted.value(forHTTPHeaderField: "Authorization"), "Bearer secret")
    }

    func testRetryPolicyRetriesOnlyTransientIdempotentFailures() {
        let policy = RetryPolicy(maxAttempts: 3, baseDelay: 0, maxDelay: 0)

        XCTAssertTrue(policy.shouldRetry(endpoint: PrivateEndpoint(), error: .timeout, attempt: 0))
        XCTAssertTrue(policy.shouldRetry(endpoint: PrivateEndpoint(), error: .serverError(statusCode: 503, message: nil), attempt: 1))
        XCTAssertFalse(policy.shouldRetry(endpoint: PrivateEndpoint(), error: .serverError(statusCode: 500, message: nil), attempt: 0))
        XCTAssertFalse(policy.shouldRetry(endpoint: MutationEndpoint(), error: .timeout, attempt: 0))
        XCTAssertFalse(policy.shouldRetry(endpoint: PrivateEndpoint(), error: .unauthorized, attempt: 0))
        XCTAssertFalse(policy.shouldRetry(endpoint: PrivateEndpoint(), error: .timeout, attempt: 2))
    }
}

private struct PublicEndpoint: APIEndpoint {
    let path = "/public"
    let requiresAuth = false
}

private struct PrivateEndpoint: APIEndpoint {
    let path = "/private"
}

private struct MutationEndpoint: APIEndpoint {
    let path = "/submit"
    let method: HTTPMethod = .post
}
