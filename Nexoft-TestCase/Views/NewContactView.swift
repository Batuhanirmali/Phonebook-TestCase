//
//  NewContactView.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI
import Lottie

struct NewContactView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = NewContactViewModel()

    var onSave: (Contact) async -> Void

    var body: some View {
        ZStack {
            NavigationStack {
                VStack(spacing: 24) {
                    AvatarPickerView(
                        image: viewModel.avatarImage,
                        onTap: {
                            viewModel.showImagePickerOverlay = true
                        }
                    )
                    .padding(.top, 24)

                    VStack(spacing: 12) {
                        TextField("First Name", text: $viewModel.firstName)
                            .textFieldStyle(ContactTextFieldStyle())

                        TextField("Last Name", text: $viewModel.lastName)
                            .textFieldStyle(ContactTextFieldStyle())

                        TextField("Phone Number", text: $viewModel.phoneNumber)
                            .keyboardType(.phonePad)
                            .textFieldStyle(ContactTextFieldStyle())
                    }
                    .padding(.horizontal, 16)

                    Spacer()
                }
                .navigationTitle("New Contact")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                        .disabled(viewModel.isSaving)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        if viewModel.isSaving {
                            ProgressView()
                        } else {
                            Button("Done") {
                                saveContact()
                            }
                            .disabled(!viewModel.isValid)
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

                        Text("New contact saved 🎉")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    private func saveContact() {
        viewModel.isSaving = true
        let contact = viewModel.createContact()

        Task {
            await onSave(contact)

            viewModel.isSaving = false
            viewModel.showSuccessAnimation = true

            // Wait for animation to complete, then dismiss
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            dismiss()
        }
    }
}
