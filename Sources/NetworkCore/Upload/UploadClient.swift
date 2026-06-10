import Foundation

public actor UploadClient {
    private let session: URLSession
    private let builder: URLRequestBuilder
    private let multipartBuilder: MultipartBuilder
    private let decoder: JSONDecoder

    public init(configuration: NetworkConfiguration, multipartBuilder: MultipartBuilder = MultipartBuilder()) {
        self.init(
            configuration: configuration,
            session: URLSession(configuration: configuration.sessionConfiguration),
            multipartBuilder: multipartBuilder
        )
    }

    public init(configuration: NetworkConfiguration, session: URLSession, multipartBuilder: MultipartBuilder = MultipartBuilder()) {
        self.session = session
        self.builder = URLRequestBuilder(environment: configuration.environment)
        self.multipartBuilder = multipartBuilder
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func upload<T: Decodable & Sendable>(
        _ endpoint: any APIEndpoint,
        form: MultipartFormData,
        responseType: T.Type
    ) async throws -> T {
        var request = try builder.build(from: MultipartEndpoint(base: endpoint))
        request.setValue("multipart/form-data; boundary=\(form.boundary)", forHTTPHeaderField: "Content-Type")
        let body = try multipartBuilder.build(form)
        let (data, response) = try await session.upload(for: request, from: body)
        try Self.validate(data: data, response: response, decoder: decoder)
        if data.isEmpty, T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    private static func validate(data: Data, response: URLResponse, decoder: JSONDecoder) throws {
        guard let http = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }
        switch http.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 422:
            let apiError = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.validationFailed(message: apiError?.message ?? "Validation failed.", fields: apiError?.errors ?? [:])
        case 400...499:
            let apiError = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.clientError(statusCode: http.statusCode, message: apiError?.message)
        case 500...599:
            let apiError = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.serverError(statusCode: http.statusCode, message: apiError?.message)
        default:
            throw NetworkError.unknown("Unexpected status code \(http.statusCode)")
        }
    }
}

private struct MultipartEndpoint: APIEndpoint {
    let base: any APIEndpoint
    var path: String { base.path }
    var method: HTTPMethod { base.method }
    var headers: [String: String] { base.headers }
    var queryItems: [URLQueryItem] { base.queryItems }
    var body: RequestBody { .none }
    var requiresAuth: Bool { base.requiresAuth }
    var timeout: TimeInterval? { base.timeout }
    var cachePolicy: URLRequest.CachePolicy { base.cachePolicy }
    var isIdempotent: Bool { false }
    var allowsRetry: Bool { false }
    var allowsCoalescing: Bool { false }
}
