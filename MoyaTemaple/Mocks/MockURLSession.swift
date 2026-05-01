//
//  MockURLSession.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 01/05/2026.
//

import Combine
import Foundation

final class MockURLSession: URLSessionInitiable {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    init(
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil
    ) {
        self.data = data
        self.response = response
        self.error = error
    }

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionDataTask {
        let data = self.data
        let response = self.response
        let error = self.error
        // We need a concrete URLSessionDataTask — use a subclass or URLProtocol approach
        // Simplest: call completion immediately on a queue and return a dummy task
        completionHandler(data, response, error)
        return URLSession.shared.dataTask(with: request) // placeholder, won't be resumed
    }

    func uploadTask(
        with request: URLRequest,
        from bodyData: Data?,
        completionHandler: @escaping @Sendable (Data?, URLResponse?, (any Error)?) -> Void
    ) -> URLSessionUploadTask {
        completionHandler(data, response, error)
        return URLSession.shared.uploadTask(with: request, from: bodyData ?? Data()) { _, _, _ in }
    }

    func dataTaskPublisher(
        for request: URLRequest
    ) -> URLSession.DataTaskPublisher {
        // This is tricky — URLSession.DataTaskPublisher can't be created without a real URLSession.
        // You may need to use URLProtocol-based mocking for this one,
        // or change the protocol to return AnyPublisher<(Data, URLResponse), URLError> instead.
        fatalError("Use URLProtocol-based mocking or change protocol signature for publisher")
    }

    func data(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse) {
        if let error { throw error }
        return (data ?? Data(), response ?? HTTPURLResponse())
    }

    func upload(
        for request: URLRequest,
        from bodyData: Data,
        delegate: (any URLSessionTaskDelegate)?
    ) async throws -> (Data, URLResponse) {
        if let error { throw error }
        return (data ?? Data(), response ?? HTTPURLResponse())
    }
}
