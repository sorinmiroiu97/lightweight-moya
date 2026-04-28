//
//  MainView.swift
//  MoyaTemaple
//
//  Created by Sorin Miroiu on 25.04.2026.
//

import SwiftUI

struct MainView: View {
    @State private var viewModel = MainViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Networking Patterns") {
                    NavigationLink("Single Requests") {
                        SingleRequestsView(viewModel: viewModel)
                    }

                    NavigationLink("Sequential (await chain)") {
                        SequentialRequestsView(viewModel: viewModel)
                    }

                    NavigationLink("Parallel (async let)") {
                        ParallelRequestsView(viewModel: viewModel)
                    }

                    NavigationLink("TaskGroup (dynamic parallel)") {
                        TaskGroupView(viewModel: viewModel)
                    }

                    NavigationLink("Combine Publisher") {
                        CombinePublisherView(viewModel: viewModel)
                    }

                    NavigationLink("Retry with Backoff") {
                        RetryView(viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("Moya Template")
        }
    }
}

#Preview {
    MainView()
}
