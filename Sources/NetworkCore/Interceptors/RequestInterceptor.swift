import Foundation

/// Transforms a URLRequest before it is sent.
/// Interceptors are applied in the order they are registered.
public protocol RequestInterceptor: Sendable {
    func adapt(_ request: URLRequest, endpoint: any APIEndpoint) async throws -> URLRequest
}
