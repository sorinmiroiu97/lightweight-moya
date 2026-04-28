//
//  Untitled.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Combine
import Foundation

protocol Endpoint {
    var baseUrlPath: String { get }
    var route: String { get }
    var urlParams: [String: Any]? { get }
    var body: Data? { get throws }
    var httpMethod: HTTPMethod { get }
    var encoding: RequestEncoding { get }

    /// this will be removed in the future
    func request<T: Decodable>(
        with service: (any NetworkInitiable)?,
        then completion: @escaping (Result<T, ApiError>) -> Void
    )

    func request<T: Decodable>(
        with service: (any NetworkInitiable)?
    ) async throws -> T

    func request<T: Decodable>(
        with service: (any NetworkInitiable)?,
        for type: T.Type
    ) -> AnyPublisher<T, ApiError>
}

extension Endpoint {
    var urlParams: [String: Any]? {
        nil
    }

    var body: Data? {
        get throws {
            nil
        }
    }

    var httpMethod: HTTPMethod {
        .post
    }

    var encoding: RequestEncoding {
        .json
    }
}

// MARK: - URL building helper

extension Endpoint {
    private func makeUrlPath() -> String {
        var urlPath = baseUrlPath + route

        switch httpMethod {
        case .get:
            if let urlParams,
               !urlParams.isEmpty {
                urlPath.append(urlParams.queryString)
            }
        default:
            break
        }
        return urlPath
    }

    /// Configures the request headers and body.
    /// For multipart requests, returns the body `Data` separately for use with upload tasks.
    /// For other encodings, sets `httpBody` directly and returns `nil`.
    private func makeBody(
        for urlRequest: inout URLRequest
    ) throws -> Data? {
        switch encoding {
        case .multipartFormData(let items):
            let formData = MultipartFormData(items: items)
            urlRequest.setValue(
                formData.contentType,
                forHTTPHeaderField: ApiServiceHelper.RequestHeader.contentType
            )
            return formData.makeBody()
        case .json, .url:
            switch httpMethod {
            case .post:
                urlRequest.httpBody = try body
            default:
                break
            }
            return nil
        }
    }
}

// MARK: - Request methods

extension Endpoint {
    func request<T: Decodable>(
        with service: (any NetworkInitiable)? = nil,
        then completion: @escaping ((Result<T, ApiError>) -> Void)
    ) {
        let service = service ?? Container.shared.apiService
        let urlPath = makeUrlPath()

        guard let url = URL(string: urlPath) else {
            completion(.failure(ApiError.invalidURL))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        ApiServiceHelper.setHeaders(to: &urlRequest)

        let uploadBody: Data?

        do {
            uploadBody = try makeBody(for: &urlRequest)
        } catch {
            if let error = error as? ApiError {
                completion(.failure(error))
            } else {
                completion(.failure(ApiError.encodingFailed(error)))
            }
            return
        }
        switch encoding {
        case .multipartFormData:
            guard let uploadBody else {
                completion(.failure(ApiError.invalidRequest))
                return
            }
            service
                .uploadData(
                    request: urlRequest,
                    body: uploadBody,
                    with: completion
                )
        case .json,
                .url:
            service
                .perform(
                    request: urlRequest,
                    with: completion
                )
        }
    }

    func request<T: Decodable>(
        with service: (any NetworkInitiable)? = nil
    ) async throws -> T {
        let service = service ?? Container.shared.apiService
        let urlPath = makeUrlPath()

        guard let url = URL(string: urlPath) else {
            throw ApiError.invalidURL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        ApiServiceHelper.setHeaders(to: &urlRequest)

        let uploadBody: Data?

        do {
            uploadBody = try makeBody(for: &urlRequest)
        } catch {
            if let error = error as? ApiError {
                throw error
            } else {
                throw ApiError.encodingFailed(error)
            }
        }
        switch encoding {
        case .multipartFormData:
            guard let uploadBody else {
                throw ApiError.invalidRequest
            }
            return try await service
                .uploadData(
                    request: urlRequest,
                    body: uploadBody
                )
        case .json,
                .url:
            return try await service
                .perform(
                    request: urlRequest
                )
        }
    }

    func request<T: Decodable>(
        with service: (any NetworkInitiable)? = nil,
        for type: T.Type
    ) -> AnyPublisher<T, ApiError> {
        let service = service ?? Container.shared.apiService
        let urlPath = makeUrlPath()

        guard let url = URL(string: urlPath) else {
            return Fail(error: ApiError.invalidURL)
                .eraseToAnyPublisher()
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = httpMethod.rawValue
        ApiServiceHelper.setHeaders(to: &urlRequest)

        let uploadBody: Data?

        do {
            uploadBody = try makeBody(for: &urlRequest)
        } catch {
            let apiError: ApiError

            if let error = error as? ApiError {
                apiError = error
            } else {
                apiError = ApiError.encodingFailed(error)
            }
            return Fail(error: apiError)
                .eraseToAnyPublisher()
        }
        switch encoding {
        case .multipartFormData:
            guard let uploadBody else {
                return Fail(error: ApiError.invalidRequest)
                    .eraseToAnyPublisher()
            }
            return service
                .uploadDataPublisher(
                    with: urlRequest,
                    body: uploadBody,
                    for: type
                )
        case .json,
                .url:
            return service
                .requestPublisher(
                    with: urlRequest,
                    for: type
                )
        }
    }
}
