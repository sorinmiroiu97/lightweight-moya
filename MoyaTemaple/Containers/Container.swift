//
//  Container.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct Container {
    static let shared = Container()

    let apiService: NetworkInitiable

    private init(
        apiService: NetworkInitiable = ApiService.shared
    ) {
        self.apiService = apiService
    }
}

// MARK: Use the mock container for tests and canvas previews; for more customization use the factory function mock
extension Container {
    static var mock: Container {
        makeMockContainer()
    }

    static func makeMockContainer(
        apiService: NetworkInitiable = MockApiService(result: .failure(.unknown))
    ) -> Container {
        Container(
            apiService: apiService
        )
    }
}

/// This property wrapper does `NOT` react to changes.
/// For `SwiftUI` views please instead use `StateInjected`.
@propertyWrapper
struct Injected<T> {
    private let keyPath: KeyPath<Container, T>

    var wrappedValue: T {
        Container.shared[keyPath: keyPath]
    }

    init(_ keyPath: KeyPath<Container, T>) {
        self.keyPath = keyPath
    }
}

/// This property wrapper `DOES` react to changes.
/// To be used within `SwiftUI` views.
@propertyWrapper
struct StateInjected<T: ObservableObject>: DynamicProperty {
    @StateObject private var object: T

    init(_ keyPath: KeyPath<Container, T>) {
        _object = StateObject(wrappedValue: Container.shared[keyPath: keyPath])
    }

    var wrappedValue: T {
        object
    }

    var projectedValue: T {
        object
    }
}
