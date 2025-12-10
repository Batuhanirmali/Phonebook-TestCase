//
//  SearchHistoryManager.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation

@MainActor
final class SearchHistoryManager: ObservableObject {
    static let shared = SearchHistoryManager()

    @Published private(set) var searchHistory: [String] = []

    private let maxHistoryCount = 10
    private let userDefaultsKey = "contactSearchHistory"

    private init() {
        loadHistory()
    }

    func addSearchQuery(_ query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)
        guard !trimmedQuery.isEmpty else { return }

        // Remove if already exists
        searchHistory.removeAll { $0.lowercased() == trimmedQuery.lowercased() }

        // Add to beginning (most recent first)
        searchHistory.insert(trimmedQuery, at: 0)

        // Limit history count
        if searchHistory.count > maxHistoryCount {
            searchHistory = Array(searchHistory.prefix(maxHistoryCount))
        }

        saveHistory()
    }

    func removeSearchQuery(_ query: String) {
        searchHistory.removeAll { $0 == query }
        saveHistory()
    }

    func clearAllHistory() {
        searchHistory.removeAll()
        saveHistory()
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.array(forKey: userDefaultsKey) as? [String] {
            searchHistory = data
        } else {
            searchHistory = []
        }
    }

    private func saveHistory() {
        UserDefaults.standard.set(searchHistory, forKey: userDefaultsKey)
    }
}
