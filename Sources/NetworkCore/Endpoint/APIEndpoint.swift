import Foundation

/// Describes a single API endpoint. Conform to this protocol for every API call.
/// Defaults are provided so most endpoints only need to declare `path` and `method`.
public protocol APIEndpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem] { get }
    var body: RequestBody { get }
    var requiresAuth: Bool { get }
    var timeout: TimeInterval? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    /// Whether repeating this request produces the same result (GET, HEAD).
    var isIdempotent: Bool { get }
    /// Whether RetryPolicy may retry on failure.
    var allowsRetry: Bool { get }
    /// Whether RequestCoalescer may deduplicate concurrent identical calls.
    var allowsCoalescing: Bool { get }
}

public extension APIEndpoint {
    var method: HTTPMethod          { .get }
    var headers: [String: String]   { [:] }
    var queryItems: [URLQueryItem]  { [] }
    var body: RequestBody           { .none }
    var requiresAuth: Bool          { true }
    var timeout: TimeInterval?      { nil }
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }

    var isIdempotent: Bool {
        switch method {
        case .get, .head: return true
        default:          return false
        }
    }

    var allowsRetry: Bool      { isIdempotent }
    var allowsCoalescing: Bool { method == .get }
}
