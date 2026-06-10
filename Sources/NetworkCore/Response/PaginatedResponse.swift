import Foundation

/// Paginated list response. Maps common server pagination patterns.
public struct PaginatedResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let data: [T]
    public let currentPage: Int?
    public let lastPage: Int?
    public let total: Int?
    public let perPage: Int?

    public var hasNextPage: Bool {
        guard let current = currentPage, let last = lastPage else { return false }
        return current < last
    }
}
