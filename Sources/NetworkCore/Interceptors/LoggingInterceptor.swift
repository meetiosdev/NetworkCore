import Foundation

/// Debug-only logging interceptor.
/// Redacts sensitive headers and body fields.
/// Log level defaults to .basic in DEBUG, .disabled in RELEASE.
public struct LoggingInterceptor: RequestInterceptor {
    private let logger: NetworkLogger

    public init(logger: NetworkLogger = NetworkLogger(level: .defaultForBuild)) {
        self.logger = logger
    }

    public func adapt(_ request: URLRequest, endpoint: any APIEndpoint) async throws -> URLRequest {
        logger.logRequest(request: request, endpoint: endpoint)
        return request
    }
}
