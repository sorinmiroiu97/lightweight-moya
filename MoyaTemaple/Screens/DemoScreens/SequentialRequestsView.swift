//
//  SequentialRequestsView.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct SequentialRequestsView: View {
    var viewModel: MainViewModel

    var body: some View {
        List {
            Section("Sequential (one after another)") {
                Button("Fetch Users → Albums → Todos") {
                    Task { await viewModel.fetchSequential() }
                }

                ForEach(viewModel.sequentialLog, id: \.self) { log in
                    Text(log)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !viewModel.sequentialUsers.isEmpty {
                    DisclosureGroup("Users (\(viewModel.sequentialUsers.count))") {
                        ForEach(viewModel.sequentialUsers) { user in
                            Text("\(user.name) – @\(user.username)").font(.caption)
                        }
                    }
                }

                if !viewModel.sequentialAlbums.isEmpty {
                    DisclosureGroup("Albums (\(viewModel.sequentialAlbums.count))") {
                        ForEach(viewModel.sequentialAlbums) { album in
                            Text(album.title).font(.caption)
                        }
                    }
                }

                if !viewModel.sequentialTodos.isEmpty {
                    DisclosureGroup("Todos (\(viewModel.sequentialTodos.count))") {
                        ForEach(viewModel.sequentialTodos) { todo in
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
        .navigationTitle("Sequential")
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
