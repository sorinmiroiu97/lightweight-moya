//
//  Utility.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 01/05/2026.
//

import Foundation

struct Utility {
    enum AppEnvironment {
        case production
        case unitTesting
        case uiTesting
        case preview
    }

    private init() {
        // empty
    }

    static var appEnvironment: AppEnvironment {
        if isRunningUnitTests {
            .unitTesting
        } else if isRunningUITests {
            .uiTesting
        } else if isPreviewEnv {
            .preview
        } else {
            .production
        }
    }

    static var isPreviewEnv: Bool {
        ProcessInfo.isPreviewEnv
    }

    static var isRunningUnitTests: Bool {
        ProcessInfo.isRunningUnitTests
    }

    static var isRunningUITests: Bool {
        ProcessInfo.isRunningUITests
    }

    static func makeURLSession() -> URLSessionInitiable {
        switch appEnvironment {
        case .production:
            makeProductionURLSession()
        case .unitTesting:
            makeMockURLSession()
        case .uiTesting:
            makeMockURLSession()
        case .preview:
            makeMockURLSession()
        }
    }

    private static func makeProductionURLSession() -> URLSessionInitiable {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 100
        return URLSession(configuration: config)
    }

    private static func makeMockURLSession() -> URLSessionInitiable {
        MockURLSession()
    }
}
