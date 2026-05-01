//
//  ProcessInfo+Environment.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 01/05/2026.
//

import Foundation

extension ProcessInfo {
    static var isPreviewEnv: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    static var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    static var isRunningUITests: Bool {
        ProcessInfo.processInfo.environment["UITESTS_RUNNING"] == "1"
    }
}
