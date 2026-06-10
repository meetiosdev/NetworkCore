import Foundation
import XCTest
@testable import NetworkCore

final class URLRequestBuilderTests: XCTestCase {
    func testBuildMergesHeadersAndJoinsPath() throws {
        let environment = APIEnvironment(
            name: "test",
            baseURL: try XCTUnwrap(URL(string: "https://api.example.com/v1/")),
            defaultHeaders: ["X-App": "network", "Accept": "text/plain"]
        )
        let endpoint = TestEndpoint(
            path: "/users",
            headers: ["Accept": "application/json"],
            queryItems: [URLQueryItem(name: "page", value: "1")]
        )

        let request = try URLRequestBuilder(environment: environment).build(from: endpoint)

        XCTAssertEqual(request.url?.absoluteString, "https://api.example.com/v1/users?page=1")
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "X-App"), "network")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
    }

    func testFormURLEncodingEscapesReservedCharacters() throws {
        let environment = APIEnvironment(name: "test", baseURL: try XCTUnwrap(URL(string: "https://api.example.com")))
        let endpoint = TestEndpoint(
            path: "login",
            method: .post,
            body: .formURLEncoded(["email": "a+b@example.com", "password": "a&b=c"])
        )

        let request = try URLRequestBuilder(environment: environment).build(from: endpoint)
        let body = try XCTUnwrap(String(data: try XCTUnwrap(request.httpBody), encoding: .utf8))

        XCTAssertEqual(body, "email=a%2Bb%40example.com&password=a%26b%3Dc")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/x-www-form-urlencoded")
    }

    func testMultipartRejectedByRequestBuilder() throws {
        let environment = APIEnvironment(name: "test", baseURL: try XCTUnwrap(URL(string: "https://api.example.com")))
        let endpoint = TestEndpoint(path: "upload", method: .post, body: .multipart(MultipartFormData()))

        XCTAssertThrowsError(try URLRequestBuilder(environment: environment).build(from: endpoint)) { error in
            guard case NetworkError.encodingFailed = error else {
                return XCTFail("Expected encodingFailed, got \(error)")
            }
        }
    }
}

private struct TestEndpoint: APIEndpoint {
    let path: String
    var method: HTTPMethod = .get
    var headers: [String: String] = [:]
    var queryItems: [URLQueryItem] = []
    var body: RequestBody = .none
}
