//
//  UserEntity.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation
import SwiftData

@Model
final class UserEntity {
    @Attribute(.unique) var id: String?
    
    var createdAt: Date
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var profileImageUrl: String?
    var localImageData: Data?
    var isInDeviceContacts: Bool
    
    init(
        id: String?,
        createdAt: Date,
        firstName: String,
        lastName: String,
        phoneNumber: String,
        profileImageUrl: String? = nil,
        localImageData: Data? = nil,
        isInDeviceContacts: Bool = false
    ) {
        self.id = id
        self.createdAt = createdAt
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.profileImageUrl = profileImageUrl
        self.localImageData = localImageData
        self.isInDeviceContacts = isInDeviceContacts
    }
}

// MARK: - Mapping from API model

extension UserEntity {
    convenience init(from api: UserResponse) {
        self.init(
            id: api.id,
            createdAt: api.createdAt,
            firstName: api.firstName ?? "",
            lastName: api.lastName ?? "",
            phoneNumber: api.phoneNumber ?? "",
            profileImageUrl: api.profileImageUrl,
            localImageData: nil,
            isInDeviceContacts: false
        )
    }
    
    func update(from api: UserResponse) {
        self.id = api.id
        self.createdAt = api.createdAt
        self.firstName = api.firstName ?? ""
        self.lastName = api.lastName ?? ""
        self.phoneNumber = api.phoneNumber ?? ""
        self.profileImageUrl = api.profileImageUrl
    }
}
