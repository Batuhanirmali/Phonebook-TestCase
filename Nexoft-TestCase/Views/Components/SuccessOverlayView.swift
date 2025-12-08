//
//  SuccessOverlayView.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI

struct SuccessOverlayView: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)

                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.green)

                    Text(message)
                        .font(.body)
                }
                .padding(24)
            }
            .frame(width: 220, height: 160)
            Spacer()
        }
        .transition(.scale.combined(with: .opacity))
    }
}
