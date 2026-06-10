import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case invalidURL
    case invalidResponse
    case encodingFailed(String)
    case decodingFailed(String)
    case unauthorized
    case forbidden
    case notFound
    case validationFailed(message: String, fields: [String: [String]])
    case clientError(statusCode: Int, message: String?)
    case serverError(statusCode: Int, message: String?)
    case timeout
    case cancelled
    case noInternet
    case transportError(URLError)
    case unknown(String)
}

extension NetworkError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid HTTP response."
        case .encodingFailed(let message):
            return "Encoding failed: \(message)"
        case .decodingFailed(let message):
            return "Decoding failed: \(message)"
        case .unauthorized:
            return "Unauthorized."
        case .forbidden:
            return "Forbidden."
        case .notFound:
            return "Not found."
        case .validationFailed(let message, _):
            return message
        case .clientError(_, let message):
            return message ?? "Client error."
        case .serverError(_, let message):
            return message ?? "Server error."
        case .timeout:
            return "Request timed out."
        case .cancelled:
            return "Request cancelled."
        case .noInternet:
            return "No internet connection."
        case .transportError(let error):
            return error.localizedDescription
        case .unknown(let message):
            return message
        }
    }
}
