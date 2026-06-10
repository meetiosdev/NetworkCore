import Foundation

/// Prevents concurrent token refresh calls.
///
/// Problem: 10 concurrent requests fail with 401.
/// Without this: 10 parallel refresh API calls flood your auth server.
/// With this: only 1 refresh runs; all others await its result.
public actor TokenRefreshCoordinator {
    private var refreshTask: Task<AuthTokens, Error>?
    private let tokenStore: TokenStore

    public init(tokenStore: TokenStore) {
        self.tokenStore = tokenStore
    }

    /// Calls `operation` exactly once even if invoked concurrently.
    /// All concurrent callers receive the same result.
    public func refresh(
        operation: @escaping @Sendable () async throws -> AuthTokens
    ) async throws -> AuthTokens {
        if let existing = refreshTask {
            return try await existing.value
        }

        let task = Task<AuthTokens, Error> { try await operation() }
        refreshTask = task

        do {
            let tokens = try await task.value
            await tokenStore.save(tokens)
            refreshTask = nil
            return tokens
        } catch {
            await tokenStore.clear()
            refreshTask = nil
            throw error
        }
    }
}
