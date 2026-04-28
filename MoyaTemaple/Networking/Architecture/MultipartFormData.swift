//
//  MultipartFormData.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

struct MultipartFormDataItem {
    let name: String
    let data: Data
    let fileName: String?

    /// Creates a file/data part. The MIME type is detected automatically from the data.
    /// If `fileName` is not provided, one is generated using UUID and the detected file extension.
    init(
        name: String,
        data: Data,
        fileName: String? = nil
    ) {
        self.name = name
        self.data = data
        self.fileName = fileName
    }

    /// Creates a plain text field part.
    init(
        name: String,
        value: String
    ) {
        self.name = name
        self.data = Data(value.utf8)
        self.fileName = nil
    }

    /// Creates a file part from a file URL.
    /// The file name is extracted from the URL automatically.
    init(
        name: String,
        fileURL: URL
    ) throws {
        self.name = name
        self.data = try Data(contentsOf: fileURL)
        self.fileName = fileURL.lastPathComponent
    }

    /// The MIME type detected from the data's file signature.
    /// Falls back to `.octetStream` if the format is not recognized.
    var resolvedMIMEType: MIMEType {
        MIMEType(data: data) ?? .octetStream
    }

    /// The file name to use in the multipart body.
    /// If none was provided, generates one from UUID + detected extension.
    var resolvedFileName: String {
        if let fileName {
            return fileName
        }
        let mimeType = resolvedMIMEType
        return "\(UUID().uuidString).\(mimeType.fileExtension)"
    }

    /// Whether this item represents a file upload (as opposed to a plain text field).
    var isFile: Bool {
        fileName != nil || MIMEType(data: data) != nil
    }
}

struct MultipartFormData {
    let boundary: String
    let items: [MultipartFormDataItem]

    init(
        items: [MultipartFormDataItem],
        boundary: String = UUID().uuidString
    ) {
        self.items = items
        self.boundary = boundary
    }

    /// The full `Content-Type` header value including the boundary.
    var contentType: String {
        ApiServiceHelper
            .RequestHeader
            .multipartFormDataContentType(
                boundary: boundary
            )
    }

    /// Builds the full multipart body `Data` per RFC 2046.
    func makeBody() -> Data {
        var body = Data()
        let crlf = "\r\n"

        for item in items {
            body.append("--\(boundary)\(crlf)")

            if item.isFile {
                let fileName = item.resolvedFileName
                let mimeType = item.resolvedMIMEType
                body.append("\(ApiServiceHelper.RequestHeader.contentDisposition): form-data; name=\"\(item.name)\"; filename=\"\(fileName)\"\(crlf)")
                body.append("\(ApiServiceHelper.RequestHeader.contentType): \(mimeType.rawValue)\(crlf)\(crlf)")
            } else {
                body.append("\(ApiServiceHelper.RequestHeader.contentDisposition): form-data; name=\"\(item.name)\"\(crlf)\(crlf)")
            }

            body.append(item.data)
            body.append(crlf)
        }

        body.append("--\(boundary)--\(crlf)")
        return body
    }
}
