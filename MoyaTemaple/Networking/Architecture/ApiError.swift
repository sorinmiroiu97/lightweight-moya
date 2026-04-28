//
//  Untitled.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

enum ApiError: Error, LocalizedError {
    case invalidURL
    case invalidRequest
    case invalidSession
    case error(error: Error)
    case requestFailed(Error)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case serverError(statusCode: Int?)
    case unknown

    var errorDescription: String? {
        switch self {
        case .error(error: let error):
            error.localizedDescription
        case .invalidURL:
            "Invalid URL"
        case .invalidRequest:
            "Invalid Request"
        case .invalidSession:
            "Invalid Session"
        case .requestFailed(let error):
            "Request failed: \(error.localizedDescription)"
        case .decodingFailed:
            "Failed to decode response"
        case .encodingFailed:
            "Failed to encode request body"
        case .serverError(let code):
            "Server error (\(code ?? -1))"
        case .unknown:
            "Unknown error"
        }
    }
}

extension Swift.Error {
    var apiErrorText: String {
        if let apiError = self as? ApiError {
            apiError.errorDescription ?? "Unknown error"
        } else {
            "Unknown error: " + self.localizedDescription
        }
    }
}
