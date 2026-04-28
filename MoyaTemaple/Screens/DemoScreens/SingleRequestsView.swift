//
//  SingleRequestsView.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct SingleRequestsView: View {
    var viewModel: MainViewModel

    var body: some View {
        List {
            // MARK: - Fetch Posts (GET)
            Section("Posts (GET)") {
                Button("Fetch Posts") {
                    Task { await viewModel.fetchPosts() }
                }
                ForEach(viewModel.posts) { post in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(post.title).font(.headline)
                        Text(post.body)
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: - Fetch Comments (GET with query param)
            Section("Comments for Post 1 (GET)") {
                Button("Fetch Comments") {
                    Task { await viewModel.fetchComments(for: 1) }
                }
                ForEach(viewModel.comments) { comment in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.name).font(.headline)
                        Text(comment.email)
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        Text(comment.body)
                            .font(.caption)
                            .lineLimit(2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: - Create Post (POST)
            Section("Create Post (POST)") {
                Button("Create Post") {
                    Task { await viewModel.createPost() }
                }
                if let post = viewModel.createdPost {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Created! ID: \(post.id ?? -1)").font(.headline)
                        Text(post.title).font(.subheadline)
                        Text(post.body)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            errorSection
        }
        .navigationTitle("Single Requests")
        .overlay { loadingOverlay }
    }

    @ViewBuilder
    private var errorSection: some View {
        if let error = viewModel.errorMessage {
            Section("Error") {
                Text(error).foregroundStyle(.red)
            }
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isLoading {
            ProgressView()
        }
    }
}
