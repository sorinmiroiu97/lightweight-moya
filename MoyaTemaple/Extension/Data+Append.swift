//
//  Data+Append.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

extension Data {
    /// Appends the UTF8 data of the string
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
