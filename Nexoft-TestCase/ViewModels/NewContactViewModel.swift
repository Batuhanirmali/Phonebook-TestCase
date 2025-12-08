//
//  NewContactViewModel.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation
import SwiftUI

@MainActor
final class NewContactViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var phoneNumber: String = ""
    @Published var avatarImage: UIImage?
    @Published var showImagePickerOverlay = false
    @Published var showImagePicker = false
    @Published var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var isSaving = false
    @Published var showSuccessAnimation = false

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

    func createContact() -> Contact {
        Contact(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces),
            localImageData: avatarImage?.jpegData(compressionQuality: 0.8)
        )
    }

    func reset() {
        firstName = ""
        lastName = ""
        phoneNumber = ""
        avatarImage = nil
        showImagePickerOverlay = false
        showImagePicker = false
    }
}
