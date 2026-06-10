# NetworkCore Usage

## Endpoint

```swift
struct ProfileEndpoint: APIEndpoint {
    let path = "/profile"
}
```

Defaults:

- method: `GET`
- headers: `[:]`
- queryItems: `[]`
- body: `.none`
- requiresAuth: `true`
- timeout: `nil`
- cachePolicy: `.useProtocolCachePolicy`
- retry: idempotent requests only
- coalescing: `GET` only

## POST JSON

```swift
struct UpdateProfileEndpoint: APIEndpoint {
    let path = "/profile"
    let method: HTTPMethod = .patch
    let body: RequestBody
    let allowsRetry = false
    let allowsCoalescing = false

    init(request: UpdateProfileDTO) {
        self.body = .json(request)
    }
}
```

## Auth Refresh

```swift
let tokenStore = TokenStore()
let refreshCoordinator = TokenRefreshCoordinator(tokenStore: tokenStore)

let client = NetworkClient(
    configuration: config,
    interceptors: [AuthInterceptor(tokenStore: tokenStore)],
    tokenRefreshCoordinator: refreshCoordinator,
    tokenRefresher: MyTokenRefresher()
)
```

When a private endpoint returns `401`, `NetworkClient` refreshes once and retries original request once. Concurrent refreshes share one task.

## Upload

```swift
var form = MultipartFormData()
form.addField(name: "title", value: "Avatar")
form.addFile(fieldName: "file", fileName: "avatar.png", mimeType: "image/png", data: imageData)

let uploadClient = UploadClient(configuration: config)
let response = try await uploadClient.upload(
    UploadEndpoint(),
    form: form,
    responseType: APIResponse<FileDTO>.self
)
```

## Certificate Pinning

Pinning is optional and disabled by default. Do not disable ATS.

```swift
let delegate = CertificatePinningDelegate(
    pinnedCertificateData: [certificateData],
    enabled: true
)

let session = URLSession(
    configuration: .enterpriseEphemeral,
    delegate: delegate,
    delegateQueue: nil
)

let pinnedClient = NetworkClient(
    configuration: config,
    session: session
)
```
