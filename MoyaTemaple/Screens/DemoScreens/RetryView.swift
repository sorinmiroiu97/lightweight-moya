//
//  RetryView.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct RetryView: View {
    var viewModel: MainViewModel

    var body: some View {
        List {
            Section("Retry with Backoff") {
                Button("Fetch Users (with retry)") {
                    Task { await viewModel.fetchWithRetry() }
                }

                ForEach(viewModel.retryLog, id: \.self) { log in
                    Text(log)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !viewModel.retryUsers.isEmpty {
                    DisclosureGroup("Users (\(viewModel.retryUsers.count))") {
                        ForEach(viewModel.retryUsers) { user in
                            Text("\(user.name) – @\(user.username)").font(.caption)
                        }
                    }
                }
            }

            errorSection
        }
        .navigationTitle("Retry")
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
