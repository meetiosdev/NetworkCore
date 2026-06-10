import Foundation

public enum AuthEndpoint: APIEndpoint {
    case login(LoginRequestDTO)
    case me
    case logout

    public var path: String {
        switch self {
        case .login:
            "/auth/login"
        case .me:
            "/auth/me"
        case .logout:
            "/auth/logout"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .login:
            .post
        case .me:
            .get
        case .logout:
            .post
        }
    }

    public var body: RequestBody {
        switch self {
        case .login(let request):
            .json(request)
        case .me, .logout:
            .none
        }
    }

    public var requiresAuth: Bool {
        switch self {
        case .login:
            false
        case .me, .logout:
            true
        }
    }

    public var allowsRetry: Bool {
        switch self {
        case .me:
            true
        case .login, .logout:
            false
        }
    }

    public var allowsCoalescing: Bool {
        if case .me = self { return true }
        return false
    }
}
