import Foundation

public struct AuthService: AuthServiceProtocol {
    private let client: any NetworkClientProtocol
    private let tokenStore: TokenStore

    public init(client: any NetworkClientProtocol, tokenStore: TokenStore) {
        self.client = client
        self.tokenStore = tokenStore
    }

    public func login(email: String, password: String) async throws -> User {
        let dto = LoginRequestDTO(email: email, password: password)
        let response = try await client.send(AuthEndpoint.login(dto), responseType: APIResponse<LoginResponseDTO>.self)
        guard let login = response.data else {
            throw NetworkError.decodingFailed("Missing login data.")
        }
        await tokenStore.save(AuthTokens(accessToken: login.accessToken, refreshToken: login.refreshToken))
        return UserMapper.map(login.user)
    }

    public func currentUser() async throws -> User {
        let response = try await client.send(AuthEndpoint.me, responseType: APIResponse<UserResponseDTO>.self)
        guard let user = response.data else {
            throw NetworkError.decodingFailed("Missing user data.")
        }
        return UserMapper.map(user)
    }

    public func logout() async throws {
        do {
            _ = try await client.send(AuthEndpoint.logout, responseType: EmptyResponse.self)
            await tokenStore.clear()
        } catch {
            await tokenStore.clear()
            throw error
        }
    }
}
