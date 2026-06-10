import Foundation
import XCTest
@testable import NetworkCore

final class ResponseAndUploadTests: XCTestCase {
    func testAPIResponseDecodesSnakeCasePayload() throws {
        let json = """
        {
          "status": true,
          "message": "ok",
          "data": { "avatar_url": "https://example.com/a.png" }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try decoder.decode(APIResponse<AvatarDTO>.self, from: json)

        XCTAssertEqual(response.status, true)
        XCTAssertEqual(response.data?.avatarUrl?.absoluteString, "https://example.com/a.png")
    }

    func testMultipartBuilderProducesClosingBoundary() throws {
        var form = MultipartFormData(boundary: "TestBoundary")
        form.addField(name: "name", value: "Swaraj")
        form.addFile(fieldName: "file", fileName: "a.txt", mimeType: "text/plain", data: Data("hello".utf8))

        let data = try MultipartBuilder().build(form)
        let body = try XCTUnwrap(String(data: data, encoding: .utf8))

        XCTAssertTrue(body.contains("--TestBoundary\r\n"))
        XCTAssertTrue(body.contains("Content-Disposition: form-data; name=\"name\""))
        XCTAssertTrue(body.contains("filename=\"a.txt\""))
        XCTAssertTrue(body.hasSuffix("--TestBoundary--\r\n"))
    }
}

private struct AvatarDTO: Decodable, Sendable {
    let avatarUrl: URL?
}
