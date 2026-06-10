import Foundation

/// Implement this in your feature module to provide token refresh logic.
/// NetworkClient's AuthInterceptor calls this when a 401 is received.
public protocol AuthTokenRefreshing: Sendable {
    func refreshTokens() async throws -> AuthTokens
}
