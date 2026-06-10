# Modeling Guide

## DTOs Match Server JSON

```swift
struct UserResponseDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let email: String
    let avatarUrl: URL?
}
```

`NetworkClient` uses `.convertFromSnakeCase`, so `avatar_url` decodes into `avatarUrl`.

## Domain Models Fit App Needs

```swift
struct User: Sendable {
    let id: Int
    let displayName: String
    let email: String
    let avatarURL: URL?
}
```

## Map DTO To Domain

```swift
enum UserMapper {
    static func map(_ dto: UserResponseDTO) -> User {
        User(id: dto.id, displayName: dto.name, email: dto.email, avatarURL: dto.avatarUrl)
    }
}
```

UI should consume domain models, not response DTOs.
