import Foundation

public struct MultipartFormData: Sendable {
    public struct File: Sendable {
        public let fieldName: String
        public let fileName: String
        public let mimeType: String
        public let data: Data?
        public let fileURL: URL?

        public init(fieldName: String, fileName: String, mimeType: String, data: Data) {
            self.fieldName = fieldName
            self.fileName = fileName
            self.mimeType = mimeType
            self.data = data
            self.fileURL = nil
        }

        public init(fieldName: String, fileName: String, mimeType: String, fileURL: URL) {
            self.fieldName = fieldName
            self.fileName = fileName
            self.mimeType = mimeType
            self.data = nil
            self.fileURL = fileURL
        }
    }

    public let boundary: String
    public var fields: [String: String]
    public var files: [File]

    public init(boundary: String = "Boundary-\(UUID().uuidString)", fields: [String: String] = [:], files: [File] = []) {
        self.boundary = boundary
        self.fields = fields
        self.files = files
    }

    public mutating func addField(name: String, value: String) {
        fields[name] = value
    }

    public mutating func addFile(fieldName: String, fileName: String, mimeType: String, data: Data) {
        files.append(File(fieldName: fieldName, fileName: fileName, mimeType: mimeType, data: data))
    }

    public mutating func addFile(fieldName: String, fileName: String, mimeType: String, fileURL: URL) {
        files.append(File(fieldName: fieldName, fileName: fileName, mimeType: mimeType, fileURL: fileURL))
    }
}
