import Foundation

/// Builds a URLRequest from an APIEndpoint + APIEnvironment.
/// Throws typed NetworkErrors — never silently fails with try?.
public struct URLRequestBuilder: Sendable {
    private let environment: APIEnvironment

    public init(environment: APIEnvironment) {
        self.environment = environment
    }

    public func build(from endpoint: any APIEndpoint) throws -> URLRequest {
        let url = joinedURL(baseURL: environment.baseURL, path: endpoint.path)

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let finalURL = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: finalURL)
        request.httpMethod = endpoint.method.rawValue
        request.cachePolicy = endpoint.cachePolicy

        if let timeout = endpoint.timeout {
            request.timeoutInterval = timeout
        }

        // Environment default headers first, endpoint headers override.
        var finalHeaders = environment.defaultHeaders
        endpoint.headers.forEach { finalHeaders[$0.key] = $0.value }

        switch endpoint.body {
        case .none:
            break

        case .json(let body):
            request.httpBody = try encodeJSON(body)
            finalHeaders["Content-Type"] = "application/json"

        case .raw(let data):
            request.httpBody = data

        case .formURLEncoded(let params):
            request.httpBody = formURLEncoded(params)
                .data(using: .utf8)
            finalHeaders["Content-Type"] = "application/x-www-form-urlencoded"

        case .multipart:
            throw NetworkError.encodingFailed(
                "Multipart bodies must be sent via UploadClient, not URLRequestBuilder."
            )
        }

        finalHeaders.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        return request
    }

    // MARK: Private

    private func encodeJSON(_ value: any Encodable) throws -> Data {
        do {
            return try JSONEncoder().encode(AnyEncodable(value))
        } catch {
            throw NetworkError.encodingFailed(error.localizedDescription)
        }
    }

    private func joinedURL(baseURL: URL, path: String) -> URL {
        var absolute = baseURL.absoluteString
        while absolute.hasSuffix("/") { absolute.removeLast() }
        let cleanPath = path.drop { $0 == "/" }
        return URL(string: absolute + "/" + cleanPath).map { $0 } ?? baseURL.appendingPathComponent(String(cleanPath))
    }

    private func formURLEncoded(_ params: [String: String]) -> String {
        params
            .sorted { $0.key < $1.key }
            .map { "\(percentEncode($0.key))=\(percentEncode($0.value))" }
            .joined(separator: "&")
    }

    private func percentEncode(_ value: String) -> String {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: ":#[]@!$&'()*+,;=")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
}

// MARK: - AnyEncodable type-erasure

private struct AnyEncodable: Encodable {
    private let value: any Encodable

    init(_ value: any Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
