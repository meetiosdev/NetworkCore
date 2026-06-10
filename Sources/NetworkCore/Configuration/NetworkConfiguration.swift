import Foundation

/// Top-level configuration object for NetworkClient.
/// Centralises all tunable knobs in one place.
public struct NetworkConfiguration: Sendable {
    public let environment: APIEnvironment
    public let sessionConfiguration: URLSessionConfiguration
    public let logLevel: LogLevel
    public let retryPolicy: RetryPolicy
    public let enableCoalescing: Bool

    public init(
        environment: APIEnvironment,
        sessionConfiguration: URLSessionConfiguration = .enterpriseDefault,
        logLevel: LogLevel = .defaultForBuild,
        retryPolicy: RetryPolicy = RetryPolicy(),
        enableCoalescing: Bool = true
    ) {
        self.environment = environment
        self.sessionConfiguration = sessionConfiguration
        self.logLevel = logLevel
        self.retryPolicy = retryPolicy
        self.enableCoalescing = enableCoalescing
    }
}
