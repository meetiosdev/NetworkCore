import Foundation

public struct NetworkLogger: Sendable {
    public let level: LogLevel
    private let redactionPolicy: RedactionPolicy

    public init(level: LogLevel = .defaultForBuild, redactionPolicy: RedactionPolicy = RedactionPolicy()) {
        self.level = level
        self.redactionPolicy = redactionPolicy
    }

    public func logRequest(request: URLRequest, endpoint: any APIEndpoint) {
        guard level == .basic || level == .verbose else { return }
        let headers = redactionPolicy.redactedHeaders(request.allHTTPHeaderFields ?? [:])
        print("[NetworkCore] request \(request.httpMethod ?? endpoint.method.rawValue) \(request.url?.absoluteString ?? "") headers=\(headers)")
        if level == .verbose, let body = redactionPolicy.safeBodyDescription(request.httpBody) {
            print("[NetworkCore] request.body \(body)")
        }
    }

    public func logSuccess(endpoint: any APIEndpoint, elapsed: TimeInterval, statusCode: Int? = nil, body: Data? = nil) {
        guard level == .basic || level == .verbose else { return }
        let status = statusCode.map { " status=\($0)" } ?? ""
        print("[NetworkCore] success \(endpoint.method.rawValue) \(endpoint.path)\(status) time=\(Self.ms(elapsed))ms")
        if level == .verbose, let body = redactionPolicy.safeBodyDescription(body) {
            print("[NetworkCore] response.body \(body)")
        }
    }

    public func logError(endpoint: any APIEndpoint, error: Error, elapsed: TimeInterval) {
        guard level != .disabled else { return }
        print("[NetworkCore] error \(endpoint.method.rawValue) \(endpoint.path) time=\(Self.ms(elapsed))ms \(error.localizedDescription)")
    }

    public func logRetry(endpoint: any APIEndpoint, attempt: Int, error: Error) {
        guard level == .basic || level == .verbose else { return }
        print("[NetworkCore] retry attempt=\(attempt + 1) \(endpoint.method.rawValue) \(endpoint.path) \(error.localizedDescription)")
    }

    public func logCoalescing(key: String) {
        guard level == .verbose else { return }
        print("[NetworkCore] coalescing key=\(key)")
    }

    public func logTokenRefresh(event: String) {
        guard level == .basic || level == .verbose else { return }
        print("[NetworkCore] token.refresh \(event)")
    }

    private static func ms(_ elapsed: TimeInterval) -> Int {
        Int((elapsed * 1000).rounded())
    }
}
