//
//  Dict+URLQuery.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

extension Dictionary {
    var queryString: String {
        var output = "?"
        for (key, value) in self {
            output += "\(key)" +
            "=" +
            "\(value)" +
            "&"
        }
        output = String(output.dropLast())
        return output.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? output
    }
}
