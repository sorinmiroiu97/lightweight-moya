//
//  TaskGroupView.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct TaskGroupView: View {
    var viewModel: MainViewModel

    var body: some View {
        List {
            Section("TaskGroup (dynamic parallel)") {
                Button("Fetch Comments for Posts 1–5") {
                    Task { await viewModel.fetchWithTaskGroup() }
                }

                ForEach(viewModel.taskGroupLog, id: \.self) { log in
                    Text(log)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !viewModel.taskGroupComments.isEmpty {
                    DisclosureGroup("All Comments (\(viewModel.taskGroupComments.count))") {
                        ForEach(viewModel.taskGroupComments) { comment in
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Post \(comment.postId) — \(comment.name)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Text(comment.email)
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }

            errorSection
        }
        .navigationTitle("TaskGroup")
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
