import Foundation

/// Core networking actor.
///
/// Responsibilities:
/// - Build URLRequest from APIEndpoint
/// - Run request interceptors (auth, headers, logging)
/// - Coalesce duplicate GET requests
/// - Retry on transient failures with exponential backoff
/// - Validate HTTP responses
/// - Decode success and error payloads
/// - Map URLErrors to NetworkError
/// - Handle cancellation cleanly
///
/// One decoder is shared for the actor lifetime — never created per request.
public actor NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let requestBuilder: URLRequestBuilder
    private let interceptors: [any RequestInterceptor]
    private let retryPolicy: RetryPolicy
    private let coalescer: RequestCoalescer?
    private let logger: NetworkLogger
    private let tokenRefreshCoordinator: TokenRefreshCoordinator?
    private let tokenRefresher: (any AuthTokenRefreshing)?

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    public init(
        configuration: NetworkConfiguration,
        interceptors: [any RequestInterceptor] = [],
        coalescer: RequestCoalescer? = RequestCoalescer(),
        tokenRefreshCoordinator: TokenRefreshCoordinator? = nil,
        tokenRefresher: (any AuthTokenRefreshing)? = nil
    ) {
        self.init(
            configuration: configuration,
            session: URLSession(configuration: configuration.sessionConfiguration),
            interceptors: interceptors,
            coalescer: coalescer,
            tokenRefreshCoordinator: tokenRefreshCoordinator,
            tokenRefresher: tokenRefresher
        )
    }

    public init(
        configuration: NetworkConfiguration,
        session: URLSession,
        interceptors: [any RequestInterceptor] = [],
        coalescer: RequestCoalescer? = RequestCoalescer(),
        tokenRefreshCoordinator: TokenRefreshCoordinator? = nil,
        tokenRefresher: (any AuthTokenRefreshing)? = nil
    ) {
        self.session = session
        self.requestBuilder = URLRequestBuilder(environment: configuration.environment)
        self.interceptors = interceptors
        self.retryPolicy = configuration.retryPolicy
        self.coalescer = configuration.enableCoalescing ? coalescer : nil
        self.logger = NetworkLogger(level: configuration.logLevel)
        self.tokenRefreshCoordinator = tokenRefreshCoordinator
        self.tokenRefresher = tokenRefresher
    }

    // MARK: Public

    public func send<T: Decodable & Sendable>(
        _ endpoint: any APIEndpoint,
        responseType: T.Type
    ) async throws -> T {
        let data = try await performWithRetry(endpoint)
        return try decode(data, as: responseType)
    }

    // MARK: Private — retry loop

    private func performWithRetry(_ endpoint: any APIEndpoint) async throws -> Data {
        var attempt = 0
        var didRefreshToken = false
        while true {
            let start = Date()
            do {
                let result = try await perform(endpoint)
                logger.logSuccess(
                    endpoint: endpoint,
                    elapsed: Date().timeIntervalSince(start),
                    statusCode: result.statusCode,
                    body: result.data
                )
                return result.data
            } catch is CancellationError {
                throw NetworkError.cancelled
            } catch {
                let mapped = mapError(error)
                if mapped == .unauthorized,
                   endpoint.requiresAuth,
                   !didRefreshToken,
                   let tokenRefreshCoordinator,
                   let tokenRefresher {
                    logger.logTokenRefresh(event: "start")
                    _ = try await tokenRefreshCoordinator.refresh {
                        try await tokenRefresher.refreshTokens()
                    }
                    logger.logTokenRefresh(event: "success")
                    didRefreshToken = true
                    continue
                }
                if retryPolicy.shouldRetry(endpoint: endpoint, error: mapped, attempt: attempt) {
                    logger.logRetry(endpoint: endpoint, attempt: attempt, error: mapped)
                    try await retryPolicy.sleepBeforeRetry(attempt: attempt)
                    attempt += 1
                    continue
                }
                logger.logError(endpoint: endpoint, error: mapped, elapsed: Date().timeIntervalSince(start))
                throw mapped
            }
        }
    }

    // MARK: Private — single attempt

    private func perform(_ endpoint: any APIEndpoint) async throws -> NetworkResult {
        var request = try requestBuilder.build(from: endpoint)
        logger.logRequest(request: request, endpoint: endpoint)

        for interceptor in interceptors {
            request = try await interceptor.adapt(request, endpoint: endpoint)
        }

        let finalRequest = request
        let operation: @Sendable () async throws -> NetworkResult = { [session, decoder] in
            let (data, response) = try await session.data(for: finalRequest)
            let statusCode = try NetworkClient.validate(data: data, response: response, decoder: decoder)
            return NetworkResult(data: data, statusCode: statusCode)
        }

        if endpoint.allowsCoalescing, let coalescer {
            logger.logCoalescing(key: finalRequest.coalescingKey)
            let data = try await coalescer.run(key: finalRequest.coalescingKey) {
                try await operation().data
            }
            return NetworkResult(data: data, statusCode: nil)
        }

        return try await operation()
    }

    // MARK: Private — decoding

    private func decode<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        if data.isEmpty, T.self == EmptyResponse.self {
            // Safe: we confirmed T is EmptyResponse
            return EmptyResponse() as! T // swiftlint:disable:this force_cast
        }
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error.localizedDescription)
        }
    }

    // MARK: Private — response validation

    private static func validate(
        data: Data,
        response: URLResponse,
        decoder: JSONDecoder
    ) throws -> Int {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            return http.statusCode

        case 401:
            throw NetworkError.unauthorized

        case 403:
            throw NetworkError.forbidden

        case 404:
            throw NetworkError.notFound

        case 422:
            let apiError = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.validationFailed(
                message: apiError?.message ?? "Validation failed.",
                fields: apiError?.errors ?? [:]
            )

        case 400...499:
            let apiError = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.clientError(
                statusCode: http.statusCode,
                message: apiError?.message
            )

        case 500...599:
            let apiError = try? decoder.decode(APIErrorResponse.self, from: data)
            throw NetworkError.serverError(
                statusCode: http.statusCode,
                message: apiError?.message
            )

        default:
            throw NetworkError.unknown("Unexpected status code \(http.statusCode)")
        }
    }

    // MARK: Private — URLError mapping

    private func mapError(_ error: Error) -> NetworkError {
        if let ne = error as? NetworkError { return ne }
        if let ue = error as? URLError {
            switch ue.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternet
            case .timedOut:
                return .timeout
            case .cancelled:
                return .cancelled
            default:
                return .transportError(ue)
            }
        }
        return .unknown(error.localizedDescription)
    }
}

private struct NetworkResult: Sendable {
    let data: Data
    let statusCode: Int?
}
