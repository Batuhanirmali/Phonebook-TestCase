//
//  ImagePickerOverlay.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI

struct ImagePickerOverlay: View {
    @Binding var isPresented: Bool
    var onCameraSelected: () -> Void
    var onGallerySelected: () -> Void

    var body: some View {
        VStack {
            VStack(spacing: 16) {
                // Camera button
                Button {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onCameraSelected()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image("camera")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Camera")
                            .font(.system(size: 18, weight: .regular))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )

                // Gallery button
                Button {
                    isPresented = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onGallerySelected()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image("gallery")
                            .resizable()
                            .frame(width: 20, height: 20)

                        Text("Gallery")
                            .font(.system(size: 18, weight: .regular))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.top, 40)
            .padding(.horizontal)

            // Cancel
            Button {
                isPresented = false
            } label: {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.top, 16)
            }

            Spacer()
        }
        .padding(.bottom, 24)
        .background(
            Color(.systemBackground)
        )
    }
}
