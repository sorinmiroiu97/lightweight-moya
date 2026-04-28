//
//  MainViewModel.swift
//  MoyaTemplate
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import Combine
import SwiftUI

@MainActor
@Observable
final class MainViewModel {
    var posts: [PlaceholderPost] = []
    var comments: [PlaceholderComment] = []
    var createdPost: PlaceholderPost?
    var errorMessage: String?
    var isLoading = false

    // Sequential results
    var sequentialUsers: [PlaceholderUser] = []
    var sequentialAlbums: [PlaceholderAlbum] = []
    var sequentialTodos: [PlaceholderTodo] = []
    var sequentialLog: [String] = []

    // Parallel results
    var parallelUsers: [PlaceholderUser] = []
    var parallelAlbums: [PlaceholderAlbum] = []
    var parallelTodos: [PlaceholderTodo] = []
    var parallelLog: [String] = []

    // TaskGroup results
    var taskGroupComments: [PlaceholderComment] = []
    var taskGroupLog: [String] = []

    // Combine results
    var publisherUsers: [PlaceholderUser] = []
    var publisherLog: [String] = []
    var cancellables = Set<AnyCancellable>()

    // Retry results
    var retryUsers: [PlaceholderUser] = []
    var retryLog: [String] = []

    private let apiService = Container.shared.apiService

    // MARK: - Single requests

    func fetchPosts() async {
        isLoading = true
        errorMessage = nil
        do {
            posts = try await JSONPlaceholderEndpoint
                .getPosts
                .request(with: apiService)
        } catch {
            errorMessage = error.apiErrorText
        }
        isLoading = false
    }

    func fetchComments(for postId: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            comments = try await JSONPlaceholderEndpoint
                .getComments(postId: postId)
                .request()
        } catch {
            errorMessage = error.apiErrorText
        }
        isLoading = false
    }

    func createPost() async {
        isLoading = true
        errorMessage = nil
        let body = CreatePostBody(
            userId: 1,
            title: "Sample Post",
            body: "This is a sample post created via the API."
        )
        do {
            createdPost = try await JSONPlaceholderEndpoint
                .createPost(body: body)
                .request()
        } catch {
            errorMessage = error.apiErrorText
        }
        isLoading = false
    }

    // MARK: - Sequential requests (one after another)

    /// Fetches users → then albums for user 1 → then todos for user 1.
    /// Each request waits for the previous one to finish before starting.
    func fetchSequential() async {
        isLoading = true
        errorMessage = nil
        sequentialUsers = []
        sequentialAlbums = []
        sequentialTodos = []
        sequentialLog = []

        do {
            sequentialLog.append("⏳ Fetching users...")
            let users: [PlaceholderUser] = try await JSONPlaceholderEndpoint
                .getUsers
                .request()
            sequentialUsers = users
            sequentialLog.append("✅ Got \(users.count) users")

            guard let firstUser = users.first else {
                return
            }

            sequentialLog.append("⏳ Fetching albums for \(firstUser.name)...")
            let albums: [PlaceholderAlbum] = try await JSONPlaceholderEndpoint
                .getAlbums(userId: firstUser.id)
                .request()
            sequentialAlbums = albums
            sequentialLog.append("✅ Got \(albums.count) albums")

            sequentialLog.append("⏳ Fetching todos for \(firstUser.name)...")
            let todos: [PlaceholderTodo] = try await JSONPlaceholderEndpoint
                .getTodos(userId: firstUser.id)
                .request()
            sequentialTodos = todos
            sequentialLog.append("✅ Got \(todos.count) todos")

            sequentialLog.append("🏁 All sequential requests done!")
        } catch {
            errorMessage = error.apiErrorText
            sequentialLog.append("❌ Error: \(error.apiErrorText)")
        }
        isLoading = false
    }

    // MARK: - Parallel requests (all at once)

    /// Fetches users, albums for user 1, and todos for user 1 all at the same time.
    /// Uses async let to fire all requests simultaneously.
    func fetchParallel() async {
        isLoading = true
        errorMessage = nil
        parallelUsers = []
        parallelAlbums = []
        parallelTodos = []
        parallelLog = []

        parallelLog.append("⏳ Firing all 3 requests at once...")

        do {
            async let usersTask: [PlaceholderUser] = JSONPlaceholderEndpoint
                .getUsers
                .request()
            async let albumsTask: [PlaceholderAlbum] = JSONPlaceholderEndpoint
                .getAlbums(userId: 1)
                .request()
            async let todosTask: [PlaceholderTodo] = JSONPlaceholderEndpoint
                .getTodos(userId: 1)
                .request()

            let (users, albums, todos) = try await (usersTask, albumsTask, todosTask)

            parallelUsers = users
            parallelAlbums = albums
            parallelTodos = todos

            parallelLog.append("✅ Got \(users.count) users")
            parallelLog.append("✅ Got \(albums.count) albums")
            parallelLog.append("✅ Got \(todos.count) todos")
            parallelLog.append("🏁 All parallel requests done!")
        } catch {
            errorMessage = error.apiErrorText
            parallelLog.append("❌ Error: \(error.apiErrorText)")
        }
        isLoading = false
    }

    // MARK: - TaskGroup (dynamic parallel requests)

    /// Fetches comments for posts 1–5 in parallel using TaskGroup.
    /// Unlike async let, TaskGroup supports a dynamic number of tasks.
    func fetchWithTaskGroup() async {
        isLoading = true
        errorMessage = nil
        taskGroupComments = []
        taskGroupLog = []

        let postIds = [1, 2, 3, 4, 5]
        taskGroupLog.append("⏳ Fetching comments for \(postIds.count) posts in parallel...")

        do {
            let allComments = try await withThrowingTaskGroup(
                of: (Int, [PlaceholderComment]).self
            ) { group in
                for postId in postIds {
                    group.addTask {
                        let comments: [PlaceholderComment] = try await JSONPlaceholderEndpoint
                            .getComments(postId: postId)
                            .request()
                        return (postId, comments)
                    }
                }
                var results: [PlaceholderComment] = []

                for try await (postId, comments) in group {
                    results.append(contentsOf: comments)
                    taskGroupLog.append("✅ Post \(postId): got \(comments.count) comments")
                }
                return results
            }

            taskGroupComments = allComments
            taskGroupLog.append("🏁 Total: \(allComments.count) comments from \(postIds.count) posts")
        } catch {
            errorMessage = error.apiErrorText
            taskGroupLog.append("❌ Error: \(error.apiErrorText)")
        }
        isLoading = false
    }

    // MARK: - Combine Publisher

    /// Fetches users using the Combine publisher API.
    func fetchWithPublisher() {
        isLoading = true
        errorMessage = nil
        publisherUsers = []
        publisherLog = []

        publisherLog.append("⏳ Fetching users via Combine publisher...")

        JSONPlaceholderEndpoint
            .getUsers
            .request(for: [PlaceholderUser].self)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else {
                        return
                    }
                    isLoading = false
                    switch completion {
                    case .finished:
                        publisherLog.append("🏁 Publisher completed!")
                    case .failure(let error):
                        errorMessage = error.errorDescription
                        publisherLog.append("❌ Error: \(error.errorDescription ?? "Unknown")")
                    }
                },
                receiveValue: { [weak self] users in
                    guard let self else {
                        return
                    }
                    publisherUsers = users
                    publisherLog.append("✅ Got \(users.count) users")
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Retry with exponential backoff

    /// Attempts to fetch users up to 3 times with increasing delay between attempts.
    func fetchWithRetry(maxAttempts: Int = 3) async {
        isLoading = true
        errorMessage = nil
        retryUsers = []
        retryLog = []

        for attempt in 1...maxAttempts {
            retryLog.append("⏳ Attempt \(attempt) of \(maxAttempts)...")

            do {
                // simulating the retry attempts
                guard attempt == maxAttempts else {
                    throw ApiError.unknown
                }

                let users: [PlaceholderUser] = try await JSONPlaceholderEndpoint
                    .getUsers
                    .request()
                retryUsers = users
                retryLog.append("✅ Success on attempt \(attempt)! Got \(users.count) users")
                isLoading = false
                return
            } catch {
                retryLog.append("⚠️ Attempt \(attempt) failed: \(error.apiErrorText)")

                if attempt == maxAttempts {
                    errorMessage = "Failed after \(maxAttempts) attempts"
                    retryLog.append("❌ All \(maxAttempts) attempts exhausted")
                } else {
                    let delay = attempt * 1 // 1s, 2s, 3s backoff
                    retryLog.append("⏳ Waiting \(delay)s before retry...")
                    try? await Task.sleep(for: .seconds(delay))
                }
            }
        }
        isLoading = false
    }
}
