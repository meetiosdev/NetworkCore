import Foundation

public enum UserMapper {
    public static func map(_ dto: UserResponseDTO) -> User {
        User(id: dto.id, displayName: dto.name, email: dto.email, avatarURL: dto.avatarUrl)
    }
}
