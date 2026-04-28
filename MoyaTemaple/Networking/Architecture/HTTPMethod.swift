//
//  HTTPMethod.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case head = "HEAD"
    case patch = "PATCH"
    case delete = "DELETE"
    case options = "OPTIONS"
}

enum RequestEncoding {
    case url
    case json
    case multipartFormData([MultipartFormDataItem])
}
