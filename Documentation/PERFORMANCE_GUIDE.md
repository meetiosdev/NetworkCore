# Performance Guide

## Defaults

- `URLSessionConfiguration.enterpriseDefault`
  - `waitsForConnectivity = true`
  - `httpMaximumConnectionsPerHost = 6`
  - protocol cache policy
  - controlled `URLCache`
  - cookies disabled
- `URLSessionConfiguration.enterpriseEphemeral`
  - no cache
  - cookies disabled
  - suited for auth/private/payment APIs

## Retry

`RetryPolicy` retries only safe transient failures:

- timeout
- no internet
- network connection lost
- HTTP `502`, `503`, `504`

It does not retry `400`, `401`, `403`, `404`, `422`, or mutations unless endpoint policy allows it.

## Coalescing

`RequestCoalescer` deduplicates in-flight duplicate `GET` requests by:

```text
method + URL + auth context
```

Do not coalesce payment, login, logout, upload, or mutation APIs.

## Logging

`NetworkLogger` redacts:

- `Authorization`
- token fields
- password
- otp
- card/payment data
- secret/private data

Use `.verbose` only for local debugging.
