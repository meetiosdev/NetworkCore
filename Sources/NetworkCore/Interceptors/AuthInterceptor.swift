import Foundation

/// Injects `Authorization: Bearer <token>` only when `endpoint.requiresAuth == true`.
/// Reads the token from TokenStore actor without blocking.
public struct AuthInterceptor: RequestInterceptor {
    private let tokenStore: TokenStore

    public init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
    }

    public func adapt(_ request: URLRequest, endpoint: any APIEndpoint) async throws -> URLRequest {
        guard endpoint.requiresAuth else { return request }

        var r = request
        if let token = await tokenStore.accessToken {
            r.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return r
    }
}
