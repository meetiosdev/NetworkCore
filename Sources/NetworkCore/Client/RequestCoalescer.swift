import Foundation

/// Deduplicates concurrent identical GET requests.
/// If 5 parts of the app fire the same endpoint simultaneously, only 1 real call is made.
/// All 5 callers receive the same result.
public actor RequestCoalescer {
    private var inFlightTasks: [String: Task<Data, Error>] = [:]

    public init() {}

    public func run(
        key: String,
        operation: @escaping @Sendable () async throws -> Data
    ) async throws -> Data {
        if let existing = inFlightTasks[key] {
            return try await existing.value
        }

        let task = Task { try await operation() }
        inFlightTasks[key] = task

        do {
            let data = try await task.value
            inFlightTasks[key] = nil
            return data
        } catch {
            inFlightTasks[key] = nil
            throw error
        }
    }
}

// MARK: - Coalescing key

extension URLRequest {
    /// Key includes method + URL + auth context to safely deduplicate requests.
    var coalescingKey: String {
        [
            httpMethod ?? "GET",
            url?.absoluteString ?? "",
            value(forHTTPHeaderField: "Authorization") ?? ""
        ].joined(separator: "|")
    }
}
