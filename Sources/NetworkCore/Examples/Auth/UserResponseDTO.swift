import Foundation

public struct UserResponseDTO: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let email: String
    public let avatarUrl: URL?

    public init(id: Int, name: String, email: String, avatarUrl: URL? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarUrl = avatarUrl
    }
}
