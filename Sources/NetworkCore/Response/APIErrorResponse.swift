import Foundation

public struct APIErrorResponse: Decodable, Sendable {
    public let message: String?
    public let errors: [String: [String]]?

    public init(message: String? = nil, errors: [String: [String]]? = nil) {
        self.message = message
        self.errors = errors
    }
}
