import Foundation

public struct LoginResponseDTO: Decodable, Sendable {
    public let accessToken: String
    public let refreshToken: String?
    public let user: UserResponseDTO

    public init(accessToken: String, refreshToken: String?, user: UserResponseDTO) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.user = user
    }
}
