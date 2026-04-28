//
//  NetworkInitiable.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Combine
import Foundation

protocol NetworkInitiable: AnyObject {
    // MARK: callback based api

    func perform<T: Decodable>(
        request: URLRequest,
        with completion: @escaping ((Result<T, ApiError>) -> Void)
    )

    func uploadData<T: Decodable>(
        request: URLRequest,
        body: Data,
        with completion: @escaping ((Result<T, ApiError>) -> Void)
    )

    // MARK: publisher based api

    func requestPublisher<T: Decodable>(
        with request: URLRequest,
        for type: T.Type
    ) -> AnyPublisher<T, ApiError>

    func uploadDataPublisher<T: Decodable>(
        with request: URLRequest,
        body: Data,
        for type: T.Type
    ) -> AnyPublisher<T, ApiError>

    // MARK: async/await based api

    func perform<T: Decodable>(
        request: URLRequest
    ) async throws -> T

    func uploadData<T: Decodable>(
        request: URLRequest,
        body: Data
    ) async throws -> T
}
