//
//  ContentView.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ContactsRootView(
            viewModel: ContactsViewModel(modelContext: modelContext)
        )
    }
}
