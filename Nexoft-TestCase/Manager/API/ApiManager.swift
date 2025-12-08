//
//  ApiManager.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation

final class APIManager {
    static let shared = APIManager()
    
    private let session: URLSession
    
    private init(session: URLSession = .shared) {
        self.session = session
    }
    
    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateString) {
                return date
            }
            
            let fmt1 = DateFormatter()
            fmt1.locale = Locale(identifier: "en_US_POSIX")
            fmt1.timeZone = TimeZone(secondsFromGMT: 0)
            fmt1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = fmt1.date(from: dateString) {
                return date
            }
            
            let fmt2 = DateFormatter()
            fmt2.locale = Locale(identifier: "en_US_POSIX")
            fmt2.timeZone = TimeZone(secondsFromGMT: 0)
            fmt2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            if let date = fmt2.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported date format: \(dateString)"
                )
            )
        }
        return decoder
    }
    
    // MARK: - Generic request helper
    
    private func makeRequest(
        path: String,
        method: String,
        body: Data? = nil,
        contentType: String? = "application/json"
    ) throws -> URLRequest {
        let url = APIEnvironment.baseURL.appendingPathComponent(path)
        print("➡️ Request URL:", url.absoluteString)
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        request.setValue(APIEnvironment.apiKey, forHTTPHeaderField: "ApiKey")
        
        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        
        if let body {
            request.httpBody = body
        }
        
        return request
    }
    
    private func perform<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let http = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200..<300).contains(http.statusCode) else {
                throw APIError.serverError(statusCode: http.statusCode, messages: nil)
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        } catch {
            throw APIError.underlying(error)
        }
    }
    
    // MARK: - Endpoints
    
    // GET /api/User/GetAll
    func getAllUsers() async throws -> UserListResponseSuccessDto {
        let request = try makeRequest(path: "/api/User/GetAll", method: "GET", body: nil)
        return try await perform(request, as: UserListResponseSuccessDto.self)
    }
    
    // GET /api/User/{id}
    func getUser(id: String) async throws -> UserResponseSuccessDto {
        let request = try makeRequest(path: "/api/User/\(id)", method: "GET", body: nil)
        return try await perform(request, as: UserResponseSuccessDto.self)
    }
    
    // POST /api/User
    func createUser(_ requestBody: CreateUserRequest) async throws -> UserResponseSuccessDto {
        let bodyData = try JSONEncoder().encode(requestBody)
        let request = try makeRequest(path: "/api/User", method: "POST", body: bodyData)
        return try await perform(request, as: UserResponseSuccessDto.self)
    }
    
    // PUT /api/User/{id}
    func updateUser(id: String, with requestBody: UpdateUserRequest) async throws -> UserResponseSuccessDto {
        let bodyData = try JSONEncoder().encode(requestBody)
        let request = try makeRequest(path: "/api/User/\(id)", method: "PUT", body: bodyData)
        return try await perform(request, as: UserResponseSuccessDto.self)
    }
    
    // DELETE /api/User/{id}
    func deleteUser(id: String) async throws -> EmptyResponseSuccessDto {
        let request = try makeRequest(path: "/api/User/\(id)", method: "DELETE")
        return try await perform(request, as: EmptyResponseSuccessDto.self)
    }
    
    // POST /api/User/UploadImage (multipart/form-data)
    func uploadImage(imageData: Data, fileName: String = "profile.jpg") async throws -> UploadImageResponseSuccessDto {
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = try makeRequest(
            path: "/api/User/UploadImage",
            method: "POST",
            body: nil,
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
        
        var body = Data()
        
        // image field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        return try await perform(request, as: UploadImageResponseSuccessDto.self)
    }
}
