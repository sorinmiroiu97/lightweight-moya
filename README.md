# 🚀 Beyond Moya: Zero Bloat, Built to Scale

> A scalable, dependency-free networking architecture for iOS with native async/await, Combine, and callback support.

---

## 1️⃣ Introduction — What Is This?

### 🏗️ Protocol-driven networking layer wrapping URLSession

A thin abstraction built entirely on Apple's URLSession API. Instead of scattering URL request logic across view models and services, all networking is routed through a single protocol-based architecture. No subclassing, no inheritance chains — just protocols and extensions.

### 📦 Standalone module — drop it into any iOS project

The entire networking layer is self-contained with zero third-party dependencies. It relies only on Foundation and Combine, both shipped with every Apple platform. Copy the files into a new project and it works immediately.

### 🔄 Supports three API paradigms simultaneously

The same endpoint definition can be consumed via completion-handler callbacks, Combine publishers, or Swift's async/await concurrency. The caller chooses the paradigm — the endpoint doesn't change. This means a single codebase can serve legacy UIKit screens using callbacks, reactive pipelines using Combine, and modern SwiftUI views using async/await.

### 🔁 1:1 translatable to RxSwift

Every Combine operator used in this architecture has a direct RxSwift counterpart. `AnyPublisher` maps to `Observable` or `Single`. The `.sink` operator maps to `.subscribe`. The `.store(in: &cancellables)` pattern maps to `.disposed(by: disposeBag)`. The `.receive(on: DispatchQueue.main)` maps to `.observe(on: MainScheduler.instance)`. A project using RxSwift can adopt this architecture by swapping Combine types for Rx types with no structural changes.

---

## 2️⃣ Architecture Overview — The Building Blocks

### 🔌 Endpoint protocol — declares what to call

Defines the shape of an API request: base URL, route, HTTP method, request body, URL parameters, and encoding strategy. Any enum or struct conforming to Endpoint becomes a fully functional API definition. The protocol uses computed properties, so each enum case can return different values.

### ⚙️ NetworkInitiable protocol — declares how to execute

An abstraction over the networking engine. It defines six methods: perform and upload for each of the three paradigms (callback, async/await, publisher). Any class conforming to this protocol can serve as the networking engine — the real ApiService for production, a MockApiService for tests.

### 🌐 ApiService — the concrete URLSession implementation

A singleton class that conforms to NetworkInitiable. It creates URLSession instances with a shared configuration (30-second request timeout, 5-minute resource timeout). It handles data tasks for regular requests and upload tasks for multipart form data. All response decoding happens in a single private decode method.

### 📋 ApiServiceHelper — centralized header management

A utility struct that manages HTTP headers (Accept, Content-Type, Authorization, etc.) and applies them uniformly to every outgoing request via a static setHeaders(to:) method. Adding a new header to all requests means changing one place.

### ⚠️ ApiError — unified error type

A single enum covering every failure mode: invalid URL, invalid request, encoding/decoding failures, server errors with HTTP status codes, and generic wrapped errors. It conforms to LocalizedError so every case provides a human-readable errorDescription. The same error type is used across callbacks, Combine, and async/await.

### 📤 MultipartFormData — file upload builder

A struct that constructs RFC 2046-compliant multipart request bodies. It auto-detects MIME types by inspecting file data signatures (magic bytes), generates unique boundary strings, and supports both file uploads and plain text form fields. The Endpoint's encoding property routes multipart requests to URLSession's upload task automatically.

### 🎁 Container — dependency injection

A simple struct-based service locator that holds all app-wide dependencies. It exposes a shared singleton for production and a static mock factory for tests and SwiftUI previews. Property wrappers (@Injected for any dependency type, @StateInjected for ObservableObject types in SwiftUI views) provide convenient access.

---

## 3️⃣ The Endpoint Protocol — Declarative API Definition

### 📝 Each endpoint is an enum case

API endpoints are modeled as enum cases with associated values for their parameters. For example, `.getComments(postId: Int)` carries the post ID as part of the case. This makes endpoints type-safe — you cannot call getComments without providing a postId.

### 🎯 Properties describe the request shape

The protocol requires computed properties: `baseUrlPath` (the server root), `route` (the path), `httpMethod` (GET, POST, etc.), `body` (encoded request data), `urlParams` (query string parameters), and `encoding` (JSON, URL, or multipart). Each enum case returns its own values via switch statements.

### 🔧 Protocol extensions provide sensible defaults

Default implementations set `httpMethod` to `.post`, `encoding` to `.json`, `body` to `nil`, and `urlParams` to `nil`. A simple GET endpoint only needs to define `baseUrlPath` and `route` — everything else falls back to defaults.

### ➕ Adding an endpoint = one enum case + one route

To add a new API call, add a case to the enum and add its route string to the `route` property's switch statement. If it uses GET, add it to `httpMethod`. If it has a body, add encoding logic. No other files need to change.

---

## 4️⃣ Three Ways to Make the Same Request

### 📞 Callback-based (completion handlers)

The traditional iOS networking pattern. The request method accepts an @escaping closure that receives a `Result<T, ApiError>`. The caller handles success and failure in a switch statement. This approach does not guarantee which thread the completion runs on — callers must dispatch to the main queue manually for UI updates.

### 🔗 Combine publisher (reactive streams)

The request method returns an `AnyPublisher<T, ApiError>`. The caller subscribes with `.sink`, receiving values and completion events. The publisher is configured with `.receive(on: DispatchQueue.main)` so UI updates happen on the main thread automatically. Subscriptions are stored in a `Set<AnyCancellable>` to keep them alive.

### ⏱️ async/await (structured concurrency)

The request method is marked `async throws` and returns the decoded type `T` directly. The caller uses `try await`, and errors are caught with standard `do/catch` blocks. This is the most readable approach — the code reads top-to-bottom like synchronous code. Swift's structured concurrency handles thread management automatically.

---

## 5️⃣ Concurrency Patterns — What You Can Do

### 📌 Single Request

One endpoint, one response. The simplest usage. Call an endpoint with try await and assign the result. The function suspends at the await point, resumes when the response arrives, and either returns the decoded model or throws an error.

### 🔗 Sequential (Dependent Chain)

Each request waits for the previous to complete. When Request B needs data from Request A (e.g., fetch a user, then fetch that user's albums), you write sequential await calls. Each line suspends until the previous completes. The code reads like synchronous imperative code but executes asynchronously without blocking any thread.

### ⚡ Parallel (async let)

Fire a fixed number of independent requests simultaneously. The async let syntax starts a child task immediately without waiting. Multiple async let declarations run concurrently. The try await line collects all results — it suspends until every task has completed. If any task throws, the others are automatically cancelled. Use this when you know exactly how many requests to fire at compile time.

### 🔀 Dynamic Parallel (TaskGroup)

Fire a variable number of requests determined at runtime. withThrowingTaskGroup creates a group of child tasks. You call group.addTask in a loop to spawn as many concurrent requests as needed — the count can come from an array, user input, or a previous API response. Results arrive in completion order (not submission order), and you collect them with for try await. Like async let, if one task fails, the group cancels remaining tasks.

### 🔁 Retry with Backoff

Automatically retry failed requests with increasing delays. A for loop wraps the request call. On failure, Task.sleep(for:) introduces a delay before the next attempt. The delay increases with each attempt (e.g., 1s, 2s, 3s) to avoid hammering a struggling server. On success, the function returns immediately. After exhausting all attempts, it surfaces the final error.

---

## 6️⃣ Multipart Upload Support

### 📦 Built-in MultipartFormData builder

The MultipartFormData struct accepts an array of MultipartFormDataItem values and assembles them into a properly formatted multipart body with boundary separators, Content-Disposition headers, and CRLF line endings per RFC 2046.

### 🎨 Automatic MIME type detection

The MIMEType initializer inspects the first bytes of file data (magic bytes / file signatures) to determine the content type — JPEG, PNG, PDF, etc. If the format is unrecognized, it falls back to application/octet-stream. No manual MIME type strings needed.

### 🔄 Same endpoint pattern for uploads

Set the encoding property to .multipartFormData([items]) on the endpoint. The Endpoint extension's makeBody method detects this encoding and returns the body data separately. The request method then routes to URLSession's upload task instead of the standard data task — all automatically.

---

## 7️⃣ Dependency Injection & Testability

### 🎁 Container as the service locator

A struct with a static shared instance that holds references to all app services (API service, analytics, etc.). It uses a private initializer with default parameter values for production dependencies and a static factory method for creating mock containers with test doubles.

### 🧪 MockApiService for testing and previews

A class conforming to NetworkInitiable that returns preconfigured Result values instead of making real network calls. Inject it via Container.makeMockContainer() to test view models in isolation or power SwiftUI canvas previews with fake data.

### 🔑 @Injected property wrapper

A lightweight property wrapper that reads a service from Container.shared using a KeyPath. Usage: `@Injected(\.apiService) private var apiService`. It resolves the dependency at access time, not at initialization, keeping the injection point concise.

### 🔌 Swap the networking layer without touching consumers

Because view models and endpoints depend on the NetworkInitiable protocol (not ApiService directly), replacing the entire networking implementation means changing one line in Container. No endpoint, view model, or view needs modification.

---

## 8️⃣ Error Handling

### 🚨 Single ApiError enum for all paradigms

Whether the request was made via callback, Combine, or async/await, failures are always delivered as ApiError. This means error handling code is consistent across the entire app — the same switch statement works everywhere.

### 🗂️ Covers the full request lifecycle

ApiError cases map to every failure point: .invalidURL (malformed URL string), .encodingFailed (body serialization error), .serverError(statusCode:) (non-2xx HTTP response), .decodingFailed (JSON parsing error), .error(error:) (underlying URLSession/network error), and .unknown (unexpected state).

### 📖 Conforms to LocalizedError

Every case provides an errorDescription string, so ApiError can be displayed directly in UI or logged without additional formatting.

---

## 9️⃣ Swift 6 Concurrency Safety

### 🔐 Sendable conformance on data models

All response and request models are declared as structs with Codable and Sendable conformance. Since they are value types with only Sendable properties (String, Int, Bool, etc.), they are inherently safe to pass across concurrency boundaries. The Sendable protocol tells the compiler this is guaranteed.

### 🎯 nonisolated on networking functions

The ApiService's async methods and its private decode function are marked nonisolated. This explicitly opts them out of any actor isolation the class might inherit, ensuring they can run on any thread. Networking and JSON decoding do not need the main thread.

### 🎬 @MainActor only on the UI layer

The @MainActor annotation is applied only to view models and SwiftUI views — the places where UI state is mutated. The networking layer, endpoint definitions, and service container remain nonisolated, keeping the main thread free from unnecessary work.

---

## 🔟 Modularity — Drop It In Any Project

### ✨ Zero third-party dependencies

The entire module uses only Foundation (URLSession, JSONEncoder/Decoder, Data) and Combine (AnyPublisher, Future). Both frameworks ship with iOS, macOS, watchOS, and tvOS. No CocoaPods, SPM packages, or Carthage dependencies to manage.

### 📂 Minimal file footprint

The core module is 5 files: Endpoint.swift, NetworkInitiable.swift, ApiService.swift, ApiServiceHelper.swift, and ApiError.swift. Add MultipartFormData.swift and MIMEType.swift if upload support is needed. Add HTTPMethod.swift for the HTTP method enum. Each file has a single responsibility.

### 🎨 Works with SwiftUI, UIKit, or mixed projects

The networking layer has no UI framework dependency. Endpoints return raw Decodable types. The caller decides how to consume them — in a SwiftUI @Observable view model, a UIKit UIViewController, or a background service.

---

## 1️⃣1️⃣ Backward Compatibility — Supporting Pre-Swift 6 Projects

### 📞 Callback API works on all Swift versions

The completion-handler-based request method uses @escaping closures and Result types, both available since Swift 5.0. Projects that have not adopted Swift concurrency or Combine can use this API immediately with no language version requirements.

### 🔗 Combine API requires iOS 13+

The publisher-based request method returns AnyPublisher, which requires the Combine framework (available since iOS 13 / macOS 10.15). Projects targeting iOS 13 or later can use this API regardless of their Swift language version setting. No Swift concurrency features are involved.

### ⏱️ async/await API requires iOS 15+ and Swift 5.5+

The async throws request method uses Swift's structured concurrency, introduced in Swift 5.5. While the async/await language syntax was back-deployed to iOS 13 in Xcode 13.2, the URLSession async APIs used in ApiService — specifically URLSession.data(for:) and URLSession.upload(for:from:) — require iOS 15 or later and were not back-deployed. This means iOS 15 is the hard minimum deployment target for the async/await API in this architecture.

### 🚀 Gradual adoption strategy

A project can start with callbacks only, add Combine publishers when ready, and eventually adopt async/await — all without changing any endpoint definitions or the networking layer itself. The three paradigms coexist in the same codebase. Migration is per-call-site, not per-module.

### 🧹 Remove concurrency annotations for pure Swift 5 projects

If the project does not use strict concurrency checking (Swift 5 language mode), the nonisolated and @MainActor annotations can be removed entirely. The Sendable conformances on model structs are harmless in Swift 5 — the compiler simply ignores them. The architecture functions identically without any concurrency annotations.

### 🏷️ @available annotations for mixed deployment targets

If the project's minimum deployment target is below iOS 15, mark the async/await request method and its protocol requirement with @available(iOS 15.0, *). The compiler will enforce that callers are inside an availability check. The callback and Combine APIs remain available unconditionally.

---

## 1️⃣2️⃣ Conclusion — Why This Matters

### 🎯 Native async/await support — something Moya doesn't offer

As of today, Moya's public API surface provides callback-based and reactive interfaces (RxSwift and Combine) but does not expose native async/await methods. This architecture goes further by adding first-class structured concurrency support, enabling sequential chains, parallel execution with async let, dynamic concurrency with TaskGroup, and retry patterns — all using Swift's native concurrency model with no wrappers or bridging layers.

### 📦 Zero dependencies — Moya requires Alamofire

Moya is built on top of Alamofire, which is itself a wrapper around URLSession. This creates a two-layer dependency chain: your code → Moya → Alamofire → URLSession. This architecture removes both intermediaries and talks to URLSession directly. The result is fewer transitive dependencies, smaller binary size, no version conflicts between packages, and no waiting for third-party maintainers to support new Xcode or Swift releases.

### ⚖️ Lighter footprint, same core pattern

Moya's key insight — modeling endpoints as enum cases conforming to a protocol — is preserved here entirely. The declarative endpoint pattern, the protocol-driven service abstraction, and the clean separation of "what to call" from "how to call it" are all present. What's removed is the abstraction overhead: no TargetType → Endpoint → URLRequest conversion chain, no plugin system, no stub closures. The architecture is deliberately minimal — it solves the networking problem and nothing else.

### 🧪 Testable by design without requiring TDD

The NetworkInitiable protocol and Container make the architecture testable by construction. MockApiService can be injected at any time — in unit tests, UI tests, or SwiftUI previews — without adopting a test-driven development workflow. Testability is a property of the architecture, not a process requirement.

### ✅ Swift 6 ready today

The architecture already handles Sendable conformance, nonisolated declarations, and @MainActor boundaries. Projects adopting strict concurrency checking or migrating to the Swift 6 language mode can use this networking layer without modification. Moya and Alamofire are still working through their own Swift 6 migration paths.

### 🔄 One architecture, three paradigms, gradual migration

A team can adopt this architecture in a legacy codebase using callbacks, introduce Combine in reactive components, and move to async/await in new features — all calling the same endpoints. This makes it practical for real-world projects where a full rewrite is not an option. Migration happens one call site at a time.

### 📖 Designed to be understood, not just used

The entire networking layer fits in under 10 files with no metaprogramming, no code generation, and no runtime magic. Every developer on the team can read, debug, and modify the networking code. When something breaks, the stack trace leads directly to URLSession — not through layers of third-party abstractions.

---

## 👤 Contributor

**Sorin Miroiu**
📧 sorinmiroiu.sm@gmail.com

---

<div align="center">

**Built with ❤️ for iOS developers who value simplicity and scalability**

</div>
