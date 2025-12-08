//
//  AvatarView.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI

struct AvatarView: View {
    var image: UIImage?
    var size: CGFloat = 44

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
