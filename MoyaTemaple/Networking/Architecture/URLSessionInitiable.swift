//
//  URLSessionInitiable.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 01/05/2026.
//

import Combine
import Foundation

protocol URLSessionInitiable: AnyObject {
    // MARK: callback based api

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDataTask

    func uploadTask(
        with request: URLRequest,
        from bodyData: Data?,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionUploadTask

    // MARK: publisher based api

    func dataTaskPublisher(
        for request: URLRequest
    ) -> URLSession.DataTaskPublisher

    // MARK: async/await based api

    func data(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse)

    func upload(
        for request: URLRequest,
        from bodyData: Data,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionInitiable {}
