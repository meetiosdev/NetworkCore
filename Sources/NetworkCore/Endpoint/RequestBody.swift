import Foundation

/// Body variants supported by URLRequestBuilder.
/// Use `.multipart` only via UploadClient — URLRequestBuilder will reject it.
public enum RequestBody: Sendable {
    case none
    case json(any Encodable & Sendable)
    case raw(Data)
    case formURLEncoded([String: String])
    case multipart(MultipartFormData)
}
