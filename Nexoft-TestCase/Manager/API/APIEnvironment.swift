//
//  APIEnvironment.swift
//  Nexoft-TestCase
//
//  Created by Talha Batuhan Irmalı on 8.12.2025.
//

import Foundation

enum APIEnvironment {
    static var baseURL: URL {
        guard let host = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("❌ BASE_URL is missing in Info.plist / xcconfig")
        }

        let urlString = "http://\(host)"
        guard let url = URL(string: urlString) else {
            fatalError("❌ Invalid BASE_URL: \(urlString)")
        }
        return url
    }

    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("❌ API_KEY is missing in Info.plist / xcconfig")
        }
        return key
    }
}

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, messages: [String]?)
    case decodingError(Error)
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let code, let messages):
            let msg = messages?.joined(separator: "\n") ?? "Unknown error"
            return "Server error (\(code))\n\(msg)"
        case .decodingError(let error):
            return "JSON parsing error: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
