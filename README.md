# NetworkCore

Native Swift networking package for iOS 15+ and macOS 12+.

```swift
import NetworkCore
```

## Install

Add this package in Xcode or `Package.swift`:

```swift
.package(url: "YOUR_REPO_URL", branch: "main")
```

Then depend on:

```swift
.product(name: "NetworkCore", package: "NetworkCore")
```

## Quick Start

```swift
struct UserEndpoint: APIEndpoint {
    let path = "/users/me"
}

let environment = APIEnvironment.production(
    baseURL: URL(string: "https://api.example.com")!
)

let config = NetworkConfiguration(environment: environment)
let tokenStore = TokenStore()
let client = NetworkClient(
    configuration: config,
    interceptors: [
        HeaderInterceptor(appVersion: "1.0.0"),
        AuthInterceptor(tokenStore: tokenStore),
        LoggingInterceptor()
    ]
)

let user = try await client.send(UserEndpoint(), responseType: APIResponse<UserResponseDTO>.self)
```

## What It Includes

- `APIEndpoint` endpoint contract with auth, timeout, cache, retry, and coalescing controls.
- `URLRequestBuilder` with safe path joining, query items, JSON, raw data, and form URL encoding.
- `NetworkClient` actor using `URLSession`, one reusable `JSONDecoder`, retry, coalescing, validation, and typed errors.
- Interceptors for standard headers, auth, and redacted logging.
- Token store and single-flight token refresh coordinator.
- Multipart upload client.
- Optional certificate pinning delegate, disabled by default.
- SwiftUI-friendly `LoadableState`.
- Auth service example with DTO/domain mapping.

See `USAGE.md`, `ARCHITECTURE.md`, `MODELING_GUIDE.md`, and `PERFORMANCE_GUIDE.md`.
