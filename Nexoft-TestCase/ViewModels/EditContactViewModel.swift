//
//  EditContactViewModel.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation
import SwiftUI

@MainActor
final class EditContactViewModel: ObservableObject {
    @Published var firstName: String
    @Published var lastName: String
    @Published var phoneNumber: String
    @Published var avatarImage: UIImage?
    @Published var showImagePickerOverlay = false
    @Published var showImagePicker = false
    @Published var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var isSaving = false
    @Published var showSuccessAnimation = false
    @Published var showOptionsMenu = false

    private let originalContact: Contact

    init(contact: Contact) {
        self.originalContact = contact
        self.firstName = contact.firstName
        self.lastName = contact.lastName
        self.phoneNumber = contact.phoneNumber
        self.avatarImage = contact.avatarImage
    }

    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func showCameraPicker() {
        imagePickerSourceType = .camera
        showImagePicker = true
    }

    func showGalleryPicker() {
        imagePickerSourceType = .photoLibrary
        showImagePicker = true
    }

    func createUpdatedContact() -> Contact {
        Contact(
            id: originalContact.id,
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
            profileImageUrl: originalContact.profileImageUrl,
            localImageData: avatarImage?.jpegData(compressionQuality: 0.8),
            createdAt: originalContact.createdAt,
            isInDeviceContacts: originalContact.isInDeviceContacts
        )
    }
}
