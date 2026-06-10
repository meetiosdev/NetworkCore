import Foundation

public protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> User
    func currentUser() async throws -> User
    func logout() async throws
}
