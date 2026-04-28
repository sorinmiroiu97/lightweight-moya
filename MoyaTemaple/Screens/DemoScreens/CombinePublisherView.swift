//
//  CombinePublisherView.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct CombinePublisherView: View {
    var viewModel: MainViewModel

    var body: some View {
        List {
            Section("Combine Publisher") {
                Button("Fetch Users (Combine)") {
                    viewModel.fetchWithPublisher()
                }

                ForEach(viewModel.publisherLog, id: \.self) { log in
                    Text(log)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if !viewModel.publisherUsers.isEmpty {
                    DisclosureGroup("Users (\(viewModel.publisherUsers.count))") {
                        ForEach(viewModel.publisherUsers) { user in
                            Text("\(user.name) – @\(user.username)").font(.caption)
                        }
                    }
                }
            }

            errorSection
        }
        .navigationTitle("Combine")
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
