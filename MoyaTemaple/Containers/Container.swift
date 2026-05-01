//
//  Container.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct Container {
    static let shared = Container()

    let apiService: any NetworkInitiable
    // here we would add more services as we need them, for example:
    // analytics, branch io, user defaults, keychain,
    // core-data store, task schedulers, other persistent stores,
    // api service, BT manager, df/deep-link service, location service,
    // notification center, push notif manager, logger etc

    private init(
        apiService: any NetworkInitiable = ApiService(urlSession: Utility.makeURLSession())
    ) {
        self.apiService = apiService
    }
}

extension Container {
    static var mock: Container {
        makeMockContainer()
    }

    static func makeMockContainer(
        // apiService: any NetworkInitiable = MockApiService(result: .failure(.unknown))
        apiService: any NetworkInitiable = ApiService(urlSession: Utility.makeURLSession())
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
