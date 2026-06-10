import Foundation
import Security

public final class CertificatePinningDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {
    private let pinnedCertificateData: Set<Data>
    private let enabled: Bool

    public init(pinnedCertificateData: Set<Data> = [], enabled: Bool = false) {
        self.pinnedCertificateData = pinnedCertificateData
        self.enabled = enabled
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard enabled else {
            return (.performDefaultHandling, nil)
        }

        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let trust = challenge.protectionSpace.serverTrust,
            SecTrustEvaluateWithError(trust, nil)
        else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let certificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate] ?? []
        for certificate in certificates {
            let data = SecCertificateCopyData(certificate) as Data
            if pinnedCertificateData.contains(data) {
                return (.useCredential, URLCredential(trust: trust))
            }
        }

        return (.cancelAuthenticationChallenge, nil)
    }
}
