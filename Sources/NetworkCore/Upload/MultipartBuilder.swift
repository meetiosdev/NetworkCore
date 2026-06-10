import Foundation

public struct MultipartBuilder: Sendable {
    public init() {}

    public func build(_ form: MultipartFormData) throws -> Data {
        var data = Data()
        let lineBreak = "\r\n"

        for (name, value) in form.fields {
            data.appendString("--\(form.boundary)\(lineBreak)")
            data.appendString("Content-Disposition: form-data; name=\"\(escape(name))\"\(lineBreak + lineBreak)")
            data.appendString(value)
            data.appendString(lineBreak)
        }

        for file in form.files {
            data.appendString("--\(form.boundary)\(lineBreak)")
            data.appendString("Content-Disposition: form-data; name=\"\(escape(file.fieldName))\"; filename=\"\(escape(file.fileName))\"\(lineBreak)")
            data.appendString("Content-Type: \(file.mimeType)\(lineBreak + lineBreak)")

            if let fileData = file.data {
                data.append(fileData)
            } else if let fileURL = file.fileURL {
                data.append(try Data(contentsOf: fileURL, options: [.mappedIfSafe]))
            }
            data.appendString(lineBreak)
        }

        data.appendString("--\(form.boundary)--\(lineBreak)")
        return data
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "\"", with: "\\\"")
    }
}

private extension Data {
    mutating func appendString(_ string: String) {
        append(Data(string.utf8))
    }
}
