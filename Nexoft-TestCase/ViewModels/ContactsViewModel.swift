//
//  ContactsViewModel.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
final class ContactsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessMessage = false

    private let modelContext: ModelContext
    private let apiManager: APIManager

    init(modelContext: ModelContext, apiManager: APIManager = .shared) {
        self.modelContext = modelContext
        self.apiManager = apiManager
    }

    // MARK: - Load Contacts

    func loadContacts() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                // First fetch from local database
                let localContacts = try fetchLocalContacts()
                contacts = localContacts

                // Then sync with API
                try await syncWithAPI()
            } catch {
                errorMessage = "Failed to load contacts: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    private func fetchLocalContacts() throws -> [Contact] {
        let descriptor = FetchDescriptor<UserEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        let entities = try modelContext.fetch(descriptor)
        return entities.map { Contact(from: $0) }
    }

    private func syncWithAPI() async throws {
        let response = try await apiManager.getAllUsers()
        guard let users = response.data.users else { return }

        for apiUser in users {
            try upsertContact(from: apiUser)
        }

        // Refresh contacts from local database after sync
        contacts = try fetchLocalContacts()
    }

    private func upsertContact(from apiUser: UserResponse) throws {
        guard let userId = apiUser.id else { return }

        let predicate = #Predicate<UserEntity> { entity in
            entity.id == userId
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        let existing = try modelContext.fetch(descriptor).first

        if let existing {
            existing.update(from: apiUser)
        } else {
            let newEntity = UserEntity(from: apiUser)
            modelContext.insert(newEntity)
        }

        try modelContext.save()
    }

    // MARK: - Add Contact

    func addContact(_ contact: Contact) async {
        isLoading = true
        errorMessage = nil

        do {
            // 1. Upload image if exists
            var imageUrl: String? = nil
            if let imageData = contact.localImageData {
                let uploadResponse = try await apiManager.uploadImage(
                    imageData: imageData,
                    fileName: "\(contact.id).jpg"
                )
                imageUrl = uploadResponse.data.imageUrl
            }

            // 2. Create contact in API
            var request = contact.toCreateRequest()
            request.profileImageUrl = imageUrl

            let response = try await apiManager.createUser(request)

            // 3. Save to local database
            let entity = UserEntity(from: response.data)
            entity.localImageData = contact.localImageData
            modelContext.insert(entity)
            try modelContext.save()

            // 4. Refresh contacts
            contacts = try fetchLocalContacts()

            showSuccessMessage = true
        } catch {
            errorMessage = "Failed to add contact: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Update Contact

    func updateContact(_ contact: Contact) async {
        isLoading = true
        errorMessage = nil

        do {
            // 1. Upload new image if changed
            var imageUrl = contact.profileImageUrl
            if let imageData = contact.localImageData, contact.profileImageUrl == nil {
                let uploadResponse = try await apiManager.uploadImage(
                    imageData: imageData,
                    fileName: "\(contact.id).jpg"
                )
                imageUrl = uploadResponse.data.imageUrl
            }

            // 2. Update in API
            var request = contact.toUpdateRequest()
            request.profileImageUrl = imageUrl

            let response = try await apiManager.updateUser(id: contact.id, with: request)

            // 3. Update local database
            let contactId = contact.id
            let predicate = #Predicate<UserEntity> { entity in
                entity.id == contactId
            }
            let descriptor = FetchDescriptor(predicate: predicate)
            if let entity = try modelContext.fetch(descriptor).first {
                entity.update(from: response.data)
                entity.localImageData = contact.localImageData
                try modelContext.save()
            }

            // 4. Refresh contacts
            contacts = try fetchLocalContacts()

            showSuccessMessage = true
        } catch {
            errorMessage = "Failed to update contact: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Delete Contact

    func deleteContact(_ contact: Contact) async {
        isLoading = true
        errorMessage = nil

        do {
            // 1. Delete from API
            _ = try await apiManager.deleteUser(id: contact.id)

            // 2. Delete from local database
            let contactId = contact.id
            let predicate = #Predicate<UserEntity> { entity in
                entity.id == contactId
            }
            let descriptor = FetchDescriptor(predicate: predicate)
            if let entity = try modelContext.fetch(descriptor).first {
                modelContext.delete(entity)
                try modelContext.save()
            }

            // 3. Refresh contacts
            contacts = try fetchLocalContacts()
        } catch {
            errorMessage = "Failed to delete contact: \(error.localizedDescription)"
        }

        isLoading = false
    }

    // MARK: - Search

    func filteredContacts(searchText: String) -> [Contact] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            return contacts
        }
        let query = searchText.lowercased()
        return contacts.filter { contact in
            contact.fullName.lowercased().contains(query) ||
            contact.phoneNumber.lowercased().contains(query)
        }
    }
}
