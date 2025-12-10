//
//  EditContactView.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI
import Lottie
import Contacts

struct EditContactView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: EditContactViewModel
    @State private var isSavedToPhone = false
    @State private var showPhoneSuccessPopup = false
    @State private var showDeleteConfirmation = false

    let startInEditMode: Bool

    var onSave: (Contact) async -> Void
    var onDelete: ((Contact) async -> Void)?

    init(contact: Contact, startInEditMode: Bool = false, onSave: @escaping (Contact) async -> Void, onDelete: ((Contact) async -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: EditContactViewModel(contact: contact))
        self.startInEditMode = startInEditMode
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 24) {
                    AvatarPickerView(
                        image: viewModel.avatarImage,
                        onTap: {
                            if viewModel.isEditMode {
                                viewModel.showImagePickerOverlay = true
                            }
                        }
                    )
                    .padding(.top, 24)

                    VStack(spacing: 12) {
                        TextField("First Name", text: $viewModel.firstName)
                            .textFieldStyle(ContactTextFieldStyle())
                            .disabled(!viewModel.isEditMode)

                        TextField("Last Name", text: $viewModel.lastName)
                            .textFieldStyle(ContactTextFieldStyle())
                            .disabled(!viewModel.isEditMode)

                        TextField("Phone Number", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                            .textFieldStyle(ContactTextFieldStyle())
                            .disabled(!viewModel.isEditMode)
                    }
                    .padding(.horizontal, 16)

                    // Save to Phone button
                    VStack(spacing: 8) {
                        Button {
                            saveToPhoneContacts()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 16))

                                Text("Save to My Phone Contact")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(isSavedToPhone ? .gray : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(isSavedToPhone ? Color.gray.opacity(0.3) : Color.primary.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isSavedToPhone || viewModel.isEditMode)

                        if isSavedToPhone {
                            HStack(spacing: 6) {
                                Image(systemName: "info.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)

                                Text("This contact is already saved your phone.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                    Spacer()
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    checkIfContactExistsInPhone()
                    if startInEditMode {
                        viewModel.isEditMode = true
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        if viewModel.isEditMode {
                            Button("Cancel") {
                                viewModel.isEditMode = false
                            }
                            .disabled(viewModel.isSaving)
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.isEditMode {
                            Button("Done") {
                                saveContact()
                            }
                            .disabled(!viewModel.isValid || viewModel.isSaving)
                        } else {
                            Button {
                                viewModel.showOptionsMenu = true
                            } label: {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(.degrees(90))
                                    .font(.system(size: 18))
                                    .foregroundStyle(.black)
                            }
                            .disabled(viewModel.isSaving)
                        }
                    }
                }
                .disabled(viewModel.isSaving || viewModel.showSuccessAnimation)
            }
            .sheet(isPresented: $viewModel.showImagePickerOverlay) {
                ImagePickerOverlay(
                    isPresented: $viewModel.showImagePickerOverlay,
                    onCameraSelected: {
                        viewModel.showCameraPicker()
                    },
                    onGallerySelected: {
                        viewModel.showGalleryPicker()
                    }
                )
                .presentationDetents([.height(250)])
                .presentationCornerRadius(22)
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(
                    image: $viewModel.avatarImage,
                    sourceType: viewModel.imagePickerSourceType
                )
                .ignoresSafeArea()
            }

            if viewModel.showSuccessAnimation {
                Color.white
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    LottieView(animation: .named("Done"))
                        .playing(loopMode: .playOnce)
                        .resizable()
                        .frame(width: 96, height: 96)

                    VStack(spacing: 4) {
                        Text("All Done!")
                            .font(.system(size: 24, weight: .semibold))

                        Text("Contact updated 🎉")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Menu bubble
            if viewModel.showOptionsMenu {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                viewModel.showOptionsMenu = false
                            }
                        }

                    VStack {
                        HStack {
                            Spacer()
                            MenuBubble(
                                showMenu: $viewModel.showOptionsMenu,
                                onEdit: {
                                    viewModel.isEditMode = true
                                },
                                onDelete: {
                                    showDeleteConfirmation = true
                                }
                            )
                            .padding(.trailing, 16)
                            .padding(.top, 60)
                        }
                        Spacer()
                    }
                }
                .transition(.opacity)
                .zIndex(2)
            }

            // Phone save success popup
            if showPhoneSuccessPopup {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)

                        Text("User is added yo your phone!")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.primary)

                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .sheet(isPresented: $showDeleteConfirmation) {
            DeleteConfirmationSheet(
                contactName: viewModel.firstName + " " + viewModel.lastName,
                onConfirm: {
                    showDeleteConfirmation = false
                    Task {
                        await onDelete?(viewModel.originalContact)
                        dismiss()
                    }
                },
                onCancel: {
                    showDeleteConfirmation = false
                }
            )
            .presentationDetents([.height(250)])
            .presentationCornerRadius(22)
            .presentationDragIndicator(.visible)
        }
    }

    private func saveContact() {
        viewModel.isSaving = true
        var contact = viewModel.createUpdatedContact()

        // Update isInDeviceContacts based on current state
        contact = Contact(
            id: contact.id,
            firstName: contact.firstName,
            lastName: contact.lastName,
            phoneNumber: contact.phoneNumber,
            profileImageUrl: contact.profileImageUrl,
            localImageData: contact.localImageData,
            createdAt: contact.createdAt,
            isInDeviceContacts: isSavedToPhone
        )

        Task {
            await onSave(contact)

            // Update phone contact if it exists
            if isSavedToPhone {
                updatePhoneContact()
            }

            viewModel.isSaving = false
            viewModel.isEditMode = false
            viewModel.showSuccessAnimation = true

            // Wait for animation to complete, then dismiss
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            dismiss()
        }
    }

    private func checkIfContactExistsInPhone() {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                print("Access denied for reading contacts")
                return
            }

            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]
            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: store.defaultContainerIdentifier())

            do {
                let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)

                // Normalize phone number for comparison (remove spaces, dashes, etc)
                let normalizedPhone = viewModel.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

                // Check if contact exists
                let exists = contacts.contains { contact in
                    let matchesName = contact.givenName.lowercased() == viewModel.firstName.lowercased() &&
                                     contact.familyName.lowercased() == viewModel.lastName.lowercased()

                    let matchesPhone = contact.phoneNumbers.contains { phoneNumber in
                        let existingPhone = phoneNumber.value.stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        return existingPhone == normalizedPhone
                    }

                    return matchesName || matchesPhone
                }

                DispatchQueue.main.async {
                    isSavedToPhone = exists
                }
            } catch {
                print("Failed to fetch contacts: \(error)")
            }
        }
    }

    private func saveToPhoneContacts() {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                print("Access denied")
                return
            }

            let contact = CNMutableContact()
            contact.givenName = viewModel.firstName
            contact.familyName = viewModel.lastName

            let phoneNumber = CNLabeledValue(
                label: CNLabelPhoneNumberMobile,
                value: CNPhoneNumber(stringValue: viewModel.phoneNumber)
            )
            contact.phoneNumbers = [phoneNumber]

            if let image = viewModel.avatarImage {
                contact.imageData = image.jpegData(compressionQuality: 0.8)
            }

            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier: nil)

            do {
                try store.execute(saveRequest)
                DispatchQueue.main.async {
                    // Show success feedback
                    withAnimation {
                        isSavedToPhone = true
                        showPhoneSuccessPopup = true
                    }

                    // Hide popup after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showPhoneSuccessPopup = false
                        }
                    }
                }
            } catch {
                print("Failed to save contact: \(error)")
            }
        }
    }

    private func updatePhoneContact() {
        let store = CNContactStore()

        store.requestAccess(for: .contacts) { granted, error in
            guard granted else {
                print("Access denied for updating contacts")
                return
            }

            let keysToFetch = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactImageDataKey,
                CNContactIdentifierKey
            ] as [CNKeyDescriptor]

            let predicate = CNContact.predicateForContactsInContainer(withIdentifier: store.defaultContainerIdentifier())

            do {
                let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                let normalizedPhone = viewModel.phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()

                // Find the matching contact by original name or phone
                if let existingContact = contacts.first(where: { contact in
                    let matchesName = contact.givenName.lowercased() == viewModel.firstName.lowercased() &&
                                     contact.familyName.lowercased() == viewModel.lastName.lowercased()

                    let matchesPhone = contact.phoneNumbers.contains { phoneNumber in
                        let existingPhone = phoneNumber.value.stringValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                        return existingPhone == normalizedPhone
                    }

                    return matchesName || matchesPhone
                }) {
                    // Create mutable copy
                    let mutableContact = existingContact.mutableCopy() as! CNMutableContact

                    // Update fields
                    mutableContact.givenName = viewModel.firstName
                    mutableContact.familyName = viewModel.lastName

                    let phoneNumber = CNLabeledValue(
                        label: CNLabelPhoneNumberMobile,
                        value: CNPhoneNumber(stringValue: viewModel.phoneNumber)
                    )
                    mutableContact.phoneNumbers = [phoneNumber]

                    if let image = viewModel.avatarImage {
                        mutableContact.imageData = image.jpegData(compressionQuality: 0.8)
                    }

                    // Save changes
                    let saveRequest = CNSaveRequest()
                    saveRequest.update(mutableContact)

                    try store.execute(saveRequest)
                    print("✅ Phone contact updated successfully")
                }
            } catch {
                print("Failed to update phone contact: \(error)")
            }
        }
    }
}

// MARK: - Menu Bubble

struct MenuBubble: View {
    @Binding var showMenu: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 14) {
                Button {
                    onEdit()
                    withAnimation(.spring()) {
                        showMenu = false
                    }
                } label: {
                    HStack {
                        Text("Edit")
                            .foregroundColor(.black)
                            .font(.system(size: 14))
                            .padding(.trailing, 50)
                        Spacer()
                        Image("edit")
                            .resizable()
                            .frame(width: 16,height: 16)
                            .foregroundColor(.black)
                    }
                }

                Divider()

                Button {
                    onDelete()
                    withAnimation(.spring()) {
                        showMenu = false
                    }
                } label: {
                    HStack {
                        Text("Delete")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                            .padding(.trailing, 50)

                        Spacer()
                        Image("delete")
                            .resizable()
                            .frame(width: 16,height: 16)
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(14)
            .background(Color.white)
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
        }
        .fixedSize()
    }
}
