//
//  MockApiService.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Combine
import Foundation

//final class MockApiService: NetworkInitiable, ObservableObject {
//    let urlSession: any URLSessionInitiable
//    
//    init(urlSession: any URLSessionInitiable) {
//        self.urlSession = urlSession
//    }
//
//    nonisolated let result: Result<Decodable, ApiError>
//
//    convenience init(result: Result<Decodable, ApiError>) {
//        self.init(urlSession: Utility.makeURLSession())
//        self.result = result
//    }
//
//    func perform<T: Decodable>(
//        request: URLRequest,
//        with completion: @escaping ((Result<T, ApiError>) -> Void)
//    ) {
//        switch result {
//        case .success(let decodableModel):
//            if let decodableModel = decodableModel as? T {
//                completion(.success(decodableModel))
//            } else {
//                completion(.failure(.decodingFailed(ApiError.unknown)))
//            }
//        case .failure(let error):
//            completion(.failure(error))
//        }
//    }
//
//    func perform<T: Decodable>(
//        request: URLRequest
//    ) async throws -> T {
//        switch result {
//        case .success(let decodableModel):
//            if let decodableModel = decodableModel as? T {
//                return decodableModel
//            } else {
//                throw ApiError.decodingFailed(ApiError.unknown)
//            }
//        case .failure(let error):
//            throw error
//        }
//    }
//
//    func requestPublisher<T: Decodable>(
//        with request: URLRequest,
//        for type: T.Type
//    ) -> AnyPublisher<T, ApiError> {
//        Future { [weak self] promise in
//            guard let self else {
//                promise(.failure(.unknown))
//                return
//            }
//            switch self.result {
//            case .success(let decodableModel):
//                if let decodableModel = decodableModel as? T {
//                    promise(.success(decodableModel))
//                } else {
//                    promise(.failure(.decodingFailed(ApiError.unknown)))
//                }
//            case .failure(let error):
//                promise(.failure(error))
//            }
//        }
//        .receive(on: DispatchQueue.main)
//        .eraseToAnyPublisher()
//    }
//
//    func uploadData<T: Decodable>(
//        request: URLRequest,
//        body: Data,
//        with completion: @escaping ((Result<T, ApiError>) -> Void)
//    ) {
//        perform(request: request, with: completion)
//    }
//
//    func uploadData<T: Decodable>(
//        request: URLRequest,
//        body: Data
//    ) async throws -> T {
//        try await perform(
//            request: request
//        )
//    }
//
//    func uploadDataPublisher<T: Decodable>(
//        with request: URLRequest,
//        body: Data,
//        for type: T.Type
//    ) -> AnyPublisher<T, ApiError> {
//        requestPublisher(with: request, for: type)
//    }
//}
