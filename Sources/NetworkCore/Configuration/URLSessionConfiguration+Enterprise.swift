import Foundation

public extension URLSessionConfiguration {

    /// Standard API session.
    /// Respects server Cache-Control headers. Keeps connection pool controlled.
    static var enterpriseDefault: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        // Wait for connectivity instead of failing instantly on poor networks.
        config.waitsForConnectivity = true
        // Default is already 6 — document the intent explicitly.
        config.httpMaximumConnectionsPerHost = 6
        // Respect server Cache-Control / Expires headers by default.
        config.requestCachePolicy = .useProtocolCachePolicy
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        // Disable cookies — API clients should not use cookie jar.
        config.httpCookieAcceptPolicy = .never
        config.httpShouldSetCookies = false
        // Controlled cache budget. Increase only for cache-heavy apps.
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,   // 10 MB
            diskCapacity: 50 * 1024 * 1024        // 50 MB
        )
        // URLSession negotiates HTTP/1.1, HTTP/2, HTTP/3 automatically.
        // Do not attempt to force HTTP/3 here.
        return config
    }

    /// Ephemeral session for auth, payment, and sensitive API calls.
    /// No disk cache, no credential storage, no cookies.
    static var enterpriseEphemeral: URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.waitsForConnectivity = true
        config.httpMaximumConnectionsPerHost = 6
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.httpCookieAcceptPolicy = .never
        config.httpShouldSetCookies = false
        config.urlCache = nil
        return config
    }
}
