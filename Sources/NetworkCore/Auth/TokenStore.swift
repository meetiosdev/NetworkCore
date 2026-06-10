import Foundation

/// In-memory token store. Actor-isolated for thread safety.
///
/// TODO: Replace in-memory storage with Keychain-backed implementation.
/// Never use UserDefaults for tokens — UserDefaults is not encrypted.
public actor TokenStore {
    private var tokens: AuthTokens?

    public init() {}

    public var accessToken: String? { tokens?.accessToken }
    public var refreshToken: String? { tokens?.refreshToken }
    public var hasTokens: Bool { tokens != nil }

    public func save(_ tokens: AuthTokens) {
        self.tokens = tokens
        // TODO: Persist to Keychain here.
    }

    public func clear() {
        tokens = nil
        // TODO: Delete from Keychain here.
    }
}
