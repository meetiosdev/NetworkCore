import Foundation

public struct RedactionPolicy: Sendable {
    private let sensitiveTerms: Set<String>

    public init(sensitiveTerms: Set<String> = RedactionPolicy.defaultSensitiveTerms) {
        self.sensitiveTerms = Set(sensitiveTerms.map { $0.lowercased() })
    }

    public static let defaultSensitiveTerms: Set<String> = [
        "authorization", "token", "access_token", "refresh_token", "password",
        "otp", "card", "payment", "secret", "private"
    ]

    public func redactedHeaders(_ headers: [AnyHashable: Any]) -> [String: String] {
        headers.reduce(into: [:]) { result, pair in
            let key = String(describing: pair.key)
            result[key] = shouldRedact(key) ? "<redacted>" : String(describing: pair.value)
        }
    }

    public func safeBodyDescription(_ data: Data?) -> String? {
        guard let data, !data.isEmpty else { return nil }
        guard let text = String(data: data, encoding: .utf8) else { return "<\(data.count) bytes>" }
        return containsSensitiveTerm(text) ? "<redacted>" : text
    }

    public func shouldRedact(_ key: String) -> Bool {
        containsSensitiveTerm(key)
    }

    private func containsSensitiveTerm(_ value: String) -> Bool {
        let lower = value.lowercased()
        return sensitiveTerms.contains { lower.contains($0) }
    }
}
