//
//  APIModels.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation

// MARK: - Requests

struct CreateUserRequest: Encodable {
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var profileImageUrl: String?
}

struct UpdateUserRequest: Encodable {
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var profileImageUrl: String?
}

// MARK: - Core responses

struct UserResponse: Decodable, Identifiable {
    var id: String?
    var createdAt: Date
    var firstName: String?
    var lastName: String?
    var phoneNumber: String?
    var profileImageUrl: String?
}

struct UserListResponse: Decodable {
    var users: [UserResponse]?
}

struct UploadImageResponse: Decodable {
    var imageUrl: String?
}

// MARK: - Success DTO wrappers

struct UserResponseSuccessDto: Decodable {
    var success: Bool
    var messages: [String]?
    var data: UserResponse
    var status: Int
}

struct UserListResponseSuccessDto: Decodable {
    var success: Bool
    var messages: [String]?
    var data: UserListResponse
    var status: Int
}

struct UploadImageResponseSuccessDto: Decodable {
    var success: Bool
    var messages: [String]?
    var data: UploadImageResponse
    var status: Int
}

// Empty response

struct EmptyResponse: Decodable {}

struct EmptyResponseSuccessDto: Decodable {
    var success: Bool
    var messages: [String]?
    var data: EmptyResponse
    var status: Int
}
