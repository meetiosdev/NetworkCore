import Foundation

/// Defines the network environment for API calls.
/// Never hardcode base URLs inside endpoint enums — inject via environment.
public struct APIEnvironment: Sendable {
    public let name: String
    public let baseURL: URL
    public let defaultHeaders: [String: String]

    public init(name: String, baseURL: URL, defaultHeaders: [String: String] = [:]) {
        self.name = name
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
    }
}

public extension APIEnvironment {
    static func development(baseURL: URL, headers: [String: String] = [:]) -> APIEnvironment {
        APIEnvironment(name: "development", baseURL: baseURL, defaultHeaders: headers)
    }

    static func staging(baseURL: URL, headers: [String: String] = [:]) -> APIEnvironment {
        APIEnvironment(name: "staging", baseURL: baseURL, defaultHeaders: headers)
    }

    static func production(baseURL: URL, headers: [String: String] = [:]) -> APIEnvironment {
        APIEnvironment(name: "production", baseURL: baseURL, defaultHeaders: headers)
    }

    static func mock(baseURL: URL, headers: [String: String] = [:]) -> APIEnvironment {
        APIEnvironment(name: "mock", baseURL: baseURL, defaultHeaders: headers)
    }
}
