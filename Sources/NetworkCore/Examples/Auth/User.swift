import Foundation

public struct User: Equatable, Sendable {
    public let id: Int
    public let displayName: String
    public let email: String
    public let avatarURL: URL?

    public init(id: Int, displayName: String, email: String, avatarURL: URL?) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
    }
}
