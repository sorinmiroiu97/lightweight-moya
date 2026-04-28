//
//  ParallelRequestsView.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct ParallelRequestsView: View {
    var viewModel: MainViewModel

    var body: some View {
        List {
            Section("Parallel (async let)") {
                Button("Fetch Users + Albums + Todos") {
                    Task { await viewModel.fetchParallel() }
                }

                ForEach(viewModel.parallelLog, id: \.self) { log in
                    Text(log)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !viewModel.parallelUsers.isEmpty {
                    DisclosureGroup("Users (\(viewModel.parallelUsers.count))") {
                        ForEach(viewModel.parallelUsers) { user in
                            Text("\(user.name) – @\(user.username)").font(.caption)
                        }
                    }
                }

                if !viewModel.parallelAlbums.isEmpty {
                    DisclosureGroup("Albums (\(viewModel.parallelAlbums.count))") {
                        ForEach(viewModel.parallelAlbums) { album in
                            Text(album.title).font(.caption)
                        }
                    }
                }

                if !viewModel.parallelTodos.isEmpty {
                    DisclosureGroup("Todos (\(viewModel.parallelTodos.count))") {
                        ForEach(viewModel.parallelTodos) { todo in
                            HStack {
                                Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(todo.completed ? .green : .gray)
                                Text(todo.title).font(.caption)
                            }
                        }
                    }
                }
            }

            errorSection
        }
        .navigationTitle("Parallel")
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
