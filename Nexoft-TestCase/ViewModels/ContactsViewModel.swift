//
//  ContactsViewModel.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation
import SwiftData
import SwiftUI
import Contacts

@MainActor
final class ContactsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessMessage = false
    @Published var showDeleteSuccessMessage = false
    @Published var shouldStartInEditMode = false

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

                // Check phone contacts status
                await syncPhoneContactsStatus()
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

    func refreshFromLocalDatabase() {
        Task {
            do {
                contacts = try fetchLocalContacts()
                // Check phone contacts status in background
                await syncPhoneContactsStatus()
            } catch {
                print("Failed to refresh from local database: \(error)")
            }
        }
    }

    private func syncWithAPI() async throws {
        let response = try await apiManager.getAllUsers()
        guard let users = response.data.users else { return }

        for apiUser in users {
            try await upsertContact(from: apiUser)
        }

        // Refresh contacts from local database after sync
        contacts = try fetchLocalContacts()

        // Debug: Log all contacts with their data status
        print("📱 Total contacts loaded: \(contacts.count)")
        for contact in contacts {
            let hasImage = contact.localImageData != nil
            let hasImageUrl = contact.profileImageUrl != nil
            print("  - \(contact.fullName) | ID: \(contact.id) | LocalImage: \(hasImage) | ImageURL: \(hasImageUrl) | InDeviceContacts: \(contact.isInDeviceContacts)")
        }
    }

    private func upsertContact(from apiUser: UserResponse) async throws {
        guard let userId = apiUser.id else { return }

        let predicate = #Predicate<UserEntity> { entity in
            entity.id == userId
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        let existing = try modelContext.fetch(descriptor).first

        if let existing {
            existing.update(from: apiUser)

            // Download image if URL exists and no local data
            if let imageUrl = apiUser.profileImageUrl,
               existing.localImageData == nil {
                await downloadAndCacheImage(imageUrl, for: existing)
            }
        } else {
            let newEntity = UserEntity(from: apiUser)
            modelContext.insert(newEntity)

            // Download image if URL exists
            if let imageUrl = apiUser.profileImageUrl {
                await downloadAndCacheImage(imageUrl, for: newEntity)
            }
        }

        try modelContext.save()
    }

    private func downloadAndCacheImage(_ urlString: String, for entity: UserEntity) async {
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            entity.localImageData = data
        } catch {
            print("Failed to download image: \(error)")
        }
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

            // 5. Check phone contacts status for the newly added contact
            await syncPhoneContactsStatus()

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
                entity.isInDeviceContacts = contact.isInDeviceContacts
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

            // 4. Show delete success message
            showDeleteSuccessMessage = true
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

    // MARK: - Phone Contacts Sync

    private func syncPhoneContactsStatus() async {
        guard !contacts.isEmpty else { return }

        await withCheckedContinuation { continuation in
            let store = CNContactStore()

            store.requestAccess(for: .contacts) { granted, error in
                guard granted else {
                    print("Access denied for reading contacts in sync")
                    continuation.resume()
                    return
                }

                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
                let predicate = CNContact.predicateForContactsInContainer(withIdentifier: store.defaultContainerIdentifier())

                do {
                    let phoneContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)

                    // Create a DispatchGroup to wait for all updates
                    let group = DispatchGroup()
                    var hasUpdates = false

                    // Update each contact's phone status
                    for contact in self.contacts {
                        let normalizedPhone = contact.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

                        let existsInPhone = phoneContacts.contains { phoneContact in
                            let matchesName = phoneContact.givenName.lowercased() == contact.firstName.lowercased() &&
                                             phoneContact.familyName.lowercased() == contact.lastName.lowercased()

                            let matchesPhone = phoneContact.phoneNumbers.contains { phoneNumber in
                                let existingPhone = phoneNumber.value.stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                                return existingPhone == normalizedPhone
                            }

                            return matchesName || matchesPhone
                        }

                        // Update database if status changed
                        if contact.isInDeviceContacts != existsInPhone {
                            hasUpdates = true
                            group.enter()
                            Task { @MainActor in
                                let contactId = contact.id
                                let predicate = #Predicate<UserEntity> { entity in
                                    entity.id == contactId
                                }
                                let descriptor = FetchDescriptor(predicate: predicate)
                                if let entity = try? self.modelContext.fetch(descriptor).first {
                                    entity.isInDeviceContacts = existsInPhone
                                    try? self.modelContext.save()
                                    print("✅ Updated phone status for \(contact.fullName): \(existsInPhone)")
                                }
                                group.leave()
                            }
                        }
                    }

                    // Wait for all updates to complete, then refresh
                    if hasUpdates {
                        group.notify(queue: .main) {
                            Task { @MainActor in
                                if let updatedContacts = try? self.fetchLocalContacts() {
                                    self.contacts = updatedContacts
                                    print("🔄 Contacts list refreshed after phone sync")
                                }
                                continuation.resume()
                            }
                        }
                    } else {
                        print("ℹ️ No phone status updates needed")
                        continuation.resume()
                    }
                } catch {
                    print("Failed to sync phone contacts status: \(error)")
                    continuation.resume()
                }
            }
        }
    }
}
