import Foundation

/// Generic API response envelope.
/// Matches the common server pattern:
/// { "status": true, "message": "...", "data": { ... } }
public struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let status: Bool?
    public let success: Bool?
    public let message: String?
    public let data: T?
}
