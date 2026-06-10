import Foundation

/// Use as the response type for endpoints that return an empty body (204, 200 with no body).
public struct EmptyResponse: Decodable, Sendable {
    public init() {}
}
