//
//  Untitled.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Combine
import Foundation

final class ApiService: NetworkInitiable, ObservableObject {

    let urlSession: any URLSessionInitiable

    required init(urlSession: any URLSessionInitiable) {
        self.urlSession = urlSession
    }

    // MARK: callback based api

    func perform<T: Decodable>(
        request: URLRequest,
        with completion: @escaping ((Result<T, ApiError>) -> Void)
    ) {
        urlSession
            .dataTask(with: request) { [weak self] data, response, error in
                guard let self else {
                    completion(.failure(ApiError.unknown))
                    return
                }
                if let error {
                    completion(.failure(ApiError.error(error: error)))
                    return
                }
                guard let data,
                      let response else {
                    completion(.failure(ApiError.invalidRequest))
                    return
                }
                do {
                    let decodedData: T = try self.decode(data: data, from: response, with: request)
                    completion(.success(decodedData))
                } catch {
                    if let error = error as? ApiError {
                        completion(.failure(error))
                        return
                    } else {
                        completion(.failure(ApiError.error(error: error)))
                        return
                    }
                }
            }.resume()
    }

    func uploadData<T: Decodable>(
        request: URLRequest,
        body: Data,
        with completion: @escaping ((Result<T, ApiError>) -> Void)
    ) {
        urlSession
            .uploadTask(with: request, from: body) { [weak self] data, response, error in
                guard let self else {
                    completion(.failure(ApiError.unknown))
                    return
                }
                if let error {
                    completion(.failure(ApiError.error(error: error)))
                    return
                }
                guard let data,
                      let response else {
                    completion(.failure(ApiError.invalidRequest))
                    return
                }
                do {
                    let decodedData: T = try self.decode(data: data, from: response, with: request)
                    completion(.success(decodedData))
                } catch {
                    if let error = error as? ApiError {
                        completion(.failure(error))
                    } else {
                        completion(.failure(ApiError.error(error: error)))
                    }
                }
            }.resume()
    }

    // MARK: publisher based api

    func requestPublisher<T: Decodable>(
        with request: URLRequest,
        for type: T.Type
    ) -> AnyPublisher<T, ApiError> {
        urlSession
            .dataTaskPublisher(for: request)
        // since url sessions tasks run on the background thread
        // there's no need to explicitly subscribe on the background thread
        // .subscribe(on: DispatchQueue.global(qos: .background))
            .tryCompactMap { [weak self] arg in
                guard let self else {
                    throw ApiError.unknown
                }
                let (data, response) = arg
                return try self.decode(data: data, from: response, with: request)
            }
            .mapError { error in
                if let error = error as? ApiError {
                    return error
                } else {
                    return ApiError.error(error: error)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func uploadDataPublisher<T: Decodable>(
        with request: URLRequest,
        body: Data,
        for type: T.Type
    ) -> AnyPublisher<T, ApiError> {
        Future<T, ApiError> { [weak self] promise in
            guard let self else {
                promise(.failure(ApiError.unknown))
                return
            }
            self.uploadData(
                request: request,
                body: body
            ) { (result: Result<T, ApiError>) in
                switch result {
                case .success(let decodedData):
                    promise(.success(decodedData))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: async/await based api

    func perform<T: Decodable>(
        request: URLRequest
    ) async throws -> T {
        if #available(iOS 15, *) {
            try await asyncPerform(request: request)
        } else {
            try await backportedAsyncPerform(request: request)
        }
    }

    func uploadData<T: Decodable>(
        request: URLRequest,
        body: Data
    ) async throws -> T {
        if #available(iOS 15, *) {
            try await asyncUploadData(request: request, body: body)
        } else {
            try await backportedAsyncUploadData(request: request, body: body)
        }
    }
}

// MARK: Async/Await functions

extension ApiService {
    @available(iOS 15, *)
    func asyncPerform<T: Decodable>(
        request: URLRequest
    ) async throws -> T {
        do {
            let (data, response) = try await urlSession
                .data(for: request, delegate: nil)
            return try decode(data: data, from: response, with: request)
        } catch {
            throw ApiError.error(error: error)
        }
    }

    func backportedAsyncPerform<T: Decodable>(
        request: URLRequest
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            perform(request: request) { (result: Result<T, ApiError>) in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @available(iOS 15, *)
    func asyncUploadData<T: Decodable>(
        request: URLRequest,
        body: Data
    ) async throws -> T {
        do {
            let (data, response) = try await urlSession
                .upload(for: request, from: body, delegate: nil)
            return try decode(data: data, from: response, with: request)
        } catch {
            throw ApiError.error(error: error)
        }
    }

    func backportedAsyncUploadData<T: Decodable>(
        request: URLRequest,
        body: Data
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            uploadData(request: request, body: body) { (result: Result<T, ApiError>) in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: Helper functions

extension ApiService {
    private func decode<T: Decodable>(
        data: Data,
        from response: URLResponse,
        with request: URLRequest
    ) throws -> T {
        let successStatusCodes = 200...299

        guard let httpResponse = response as? HTTPURLResponse,
              successStatusCodes.contains(httpResponse.statusCode) else {
            throw ApiError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ApiError.decodingFailed(error)
        }
    }

    // MARK: Debug and logging functions

    private func makePrettyPrintedJSON(from data: Data?) -> String? {
        guard let data,
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return nil
        }
        return prettyString
    }

    private func makeString(from body: Data?) -> String {
        if let body,
           let jsonString = String(data: body, encoding: .utf8) {
            return "\(jsonString as AnyObject)"
        }
        return "NIL"
    }
}
