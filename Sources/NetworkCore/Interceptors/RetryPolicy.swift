import Foundation

/// Exponential backoff with jitter.
/// Formula: delay = min(baseDelay * 2^attempt + random(0, 0.4), maxDelay)
/// Uses Task.sleep — never blocks a thread.
public struct RetryPolicy: Sendable {
    public let maxAttempts: Int
    public let baseDelay: TimeInterval
    public let maxDelay: TimeInterval

    public init(
        maxAttempts: Int = 3,
        baseDelay: TimeInterval = 0.5,
        maxDelay: TimeInterval = 8.0
    ) {
        self.maxAttempts = maxAttempts
        self.baseDelay = baseDelay
        self.maxDelay = maxDelay
    }

    /// Returns true if the request should be retried.
    /// Checks endpoint policy first, then error type.
    public func shouldRetry(endpoint: any APIEndpoint, error: NetworkError, attempt: Int) -> Bool {
        guard endpoint.allowsRetry else { return false }
        guard attempt < maxAttempts - 1 else { return false }

        switch error {
        case .timeout, .noInternet:
            return true
        case .transportError(let urlError):
            return urlError.code == .networkConnectionLost || urlError.code == .timedOut
        case .serverError(let code, _):
            return code == 502 || code == 503 || code == 504
        default:
            return false
        }
    }

    /// Async sleep before next retry attempt. Does not block.
    public func sleepBeforeRetry(attempt: Int) async throws {
        let exp    = baseDelay * pow(2.0, Double(attempt))
        let jitter = Double.random(in: 0...0.4)
        let delay  = min(exp + jitter, maxDelay)
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
}
