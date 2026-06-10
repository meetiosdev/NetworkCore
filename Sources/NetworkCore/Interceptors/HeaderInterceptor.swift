import Foundation

/// Injects standard request headers: Accept, Accept-Encoding, X-Platform,
/// X-App-Version, Accept-Language, X-Request-ID.
public struct HeaderInterceptor: RequestInterceptor {
    private let appVersion: String
    private let platform: String
    private let languageProvider: @Sendable () -> String

    public init(
        appVersion: String,
        platform: String = "ios",
        languageProvider: @escaping @Sendable () -> String = {
            Locale.current.identifier.split(separator: "_").first.map(String.init) ?? "en"
        }
    ) {
        self.appVersion = appVersion
        self.platform = platform
        self.languageProvider = languageProvider
    }

    public func adapt(_ request: URLRequest, endpoint: any APIEndpoint) async throws -> URLRequest {
        var r = request
        r.setValue("application/json",    forHTTPHeaderField: "Accept")
        r.setValue("gzip, deflate, br",   forHTTPHeaderField: "Accept-Encoding")
        r.setValue(platform,              forHTTPHeaderField: "X-Platform")
        r.setValue(appVersion,            forHTTPHeaderField: "X-App-Version")
        r.setValue(languageProvider(),    forHTTPHeaderField: "Accept-Language")
        r.setValue(UUID().uuidString,     forHTTPHeaderField: "X-Request-ID")
        return r
    }
}
