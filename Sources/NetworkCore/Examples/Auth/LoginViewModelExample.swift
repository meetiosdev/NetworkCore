import Foundation
import SwiftUI

@MainActor
public final class LoginViewModelExample: ObservableObject {
    @Published public private(set) var state: LoadableState<User> = .idle
    @Published public var email = ""
    @Published public var password = ""

    private let service: any AuthServiceProtocol
    private var loginTask: Task<Void, Never>?

    public init(service: any AuthServiceProtocol) {
        self.service = service
    }

    public func login() {
        loginTask?.cancel()
        state = .loading
        loginTask = Task { [email, password, service] in
            do {
                let user = try await service.login(email: email, password: password)
                guard !Task.isCancelled else { return }
                state = .loaded(user)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failed(error)
            }
        }
    }

    public func cancel() {
        loginTask?.cancel()
        loginTask = nil
        state = .idle
    }
}
