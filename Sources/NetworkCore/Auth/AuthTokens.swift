import Foundation

/// Access and refresh tokens. Sendable for safe cross-actor passing.
public struct AuthTokens: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String?

    public init(accessToken: String, refreshToken: String? = nil) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
