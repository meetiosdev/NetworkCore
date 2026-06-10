# NetworkCore Architecture

```text
Feature / ViewModel
↓
Service / Repository
↓
NetworkClientProtocol
↓
APIEndpoint
↓
URLRequestBuilder
↓
RequestInterceptor chain
↓
RequestCoalescer
↓
RetryPolicy
↓
URLSession
↓
Response validation
↓
DTO decode
↓
Domain mapper
↓
UI
```

## Layers

- `Environment`: base URL and default headers.
- `Configuration`: session config, retry policy, logging level, coalescing.
- `Endpoint`: method, path, headers, query, body, auth, timeout, cache, retry, coalescing.
- `Client`: request build, interceptors, transport, retry, coalescing, decoding.
- `Interceptors`: headers, auth, logging.
- `Auth`: token cache, refresh abstraction, single-flight refresh coordinator.
- `Response`: success envelope, error envelope, empty response, pagination.
- `Upload`: multipart form data and upload client.
- `Security`: optional certificate pinning. ATS stays enabled.
- `State`: small UI state helper.

## Rules

- `NetworkClient` is an actor. Do not make it `ObservableObject`.
- Tokens never go in `UserDefaults`.
- POST, payment, login, logout, and mutations do not retry/coalesce by default.
- DTOs match server JSON. Domain models stay clean for UI/business logic.
- Logs redact sensitive headers and body fields.
