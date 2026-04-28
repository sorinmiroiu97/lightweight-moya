//
//  JSONEncoder+Custom.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 26.04.2026.
//

import Foundation

extension JSONEncoder {
    static var custom: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let string = formatter.string(from: date)
            try container.encode(string)
        }
        return encoder
    }
}
