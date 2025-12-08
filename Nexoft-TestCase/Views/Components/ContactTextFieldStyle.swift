//
//  ContactTextFieldStyle.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import SwiftUI

struct ContactTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
    }
}
