//
//  ApiServiceHelper.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

struct ApiServiceHelper {
    enum RequestHeader {
        // generic http headers
        static let valueHeaderAny = "*/*"
        static let accept = "Accept"
        static let contentType = "Content-Type"
        static let contentDisposition = "Content-Disposition"
        static let valueHeaderJson = "application/json"
        static let authorization = "Authorization"

        static func multipartFormDataContentType(boundary: String) -> String {
            "multipart/form-data; boundary=\(boundary)"
        }
    }

    private init() {
        // empty implementation
    }

    static var headers: [String: String?] {
        let headers = [
            RequestHeader.accept: RequestHeader.valueHeaderJson,
            RequestHeader.contentType: RequestHeader.valueHeaderJson
        ]
        // add here any other headers we might need
        return headers
    }

    static func setHeaders(to urlRequest: inout URLRequest) {
        headers.forEach { args in
            let (key, value) = args
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
    }
}
