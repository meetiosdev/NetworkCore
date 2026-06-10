import Foundation

/// Protocol for the main network client.
/// Depend on this in your services/repositories — never on the concrete NetworkClient.
public protocol NetworkClientProtocol: Sendable {
    func send<T: Decodable & Sendable>(
        _ endpoint: any APIEndpoint,
        responseType: T.Type
    ) async throws -> T
}
