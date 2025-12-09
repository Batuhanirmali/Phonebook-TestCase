//
//  Contact.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation
import UIKit

// MARK: - Domain Model

struct Contact: Identifiable, Equatable, Hashable {
    let id: String
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var profileImageUrl: String?
    var localImageData: Data?
    var createdAt: Date
    var isInDeviceContacts: Bool

    // Custom Hashable implementation based on ID only
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Custom Equatable implementation based on ID only
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }

    var fullName: String {
        let full = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        return full.isEmpty ? phoneNumber : full
    }

    var avatarImage: UIImage? {
        guard let data = localImageData else { return nil }
        return UIImage(data: data)
    }

    init(
        id: String = UUID().uuidString,
        firstName: String,
        lastName: String,
        phoneNumber: String,
        profileImageUrl: String? = nil,
        localImageData: Data? = nil,
        createdAt: Date = Date(),
        isInDeviceContacts: Bool = false
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.profileImageUrl = profileImageUrl
        self.localImageData = localImageData
        self.createdAt = createdAt
        self.isInDeviceContacts = isInDeviceContacts
    }
}

// MARK: - Mapping from UserEntity

extension Contact {
    init(from entity: UserEntity) {
        self.init(
            id: entity.id ?? UUID().uuidString,
            firstName: entity.firstName,
            lastName: entity.lastName,
            phoneNumber: entity.phoneNumber,
            profileImageUrl: entity.profileImageUrl,
            localImageData: entity.localImageData,
            createdAt: entity.createdAt,
            isInDeviceContacts: entity.isInDeviceContacts
        )
    }
}

// MARK: - Mapping to API Request

extension Contact {
    func toCreateRequest() -> CreateUserRequest {
        CreateUserRequest(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            profileImageUrl: profileImageUrl
        )
    }

    func toUpdateRequest() -> UpdateUserRequest {
        UpdateUserRequest(
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            profileImageUrl: profileImageUrl
        )
    }
}
