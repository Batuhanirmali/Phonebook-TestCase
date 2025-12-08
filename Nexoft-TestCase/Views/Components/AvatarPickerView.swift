//
//  AvatarPickerView.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI

struct AvatarPickerView: View {
    var image: UIImage?
    var onTap: () -> Void

    private var dominantColor: Color {
        image?.getDominantColor() ?? .gray
    }

    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                ZStack {
                    VStack(spacing: 12) {
                        if let image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 96, height: 96)
                                .clipShape(Circle())
                                .shadow(color: dominantColor.opacity(0.9), radius: 30, x: 0, y: 10)
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 96, height: 96)

                                Image(systemName: "person.crop.circle")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary)
                            }
                        }
                        Text(image == nil ? "Add Photo" : "Change Photo")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }

                }
            }

        }
    }
}
