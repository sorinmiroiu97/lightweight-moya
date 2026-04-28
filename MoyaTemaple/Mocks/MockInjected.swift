//
//  MockInjected.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Foundation

/// This property wrapper does `NOT` react to changes.
/// To be used `ONLY` within test files and functions,
/// not in production!
@propertyWrapper
struct MockInjected<T> {
    private let keyPath: KeyPath<Container, T>

    var wrappedValue: T {
        Container.mock[keyPath: keyPath]
    }

    init(_ keyPath: KeyPath<Container, T>) {
        self.keyPath = keyPath
    }
}
