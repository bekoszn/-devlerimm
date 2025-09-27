//
//  APIError.swift
//  APIExplorer
//
//  Created by Berke Özgüder on 27.09.2025.
//


import Foundation

enum APIError: LocalizedError, Equatable {
    case invalidURL
    case decodingFailed
    case httpStatus(Int)
    case network(URLError)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .decodingFailed:
            return "Failed to decode server response"
        case .httpStatus(let code):
            return "Server error (status: \(code))"
        case .network(let e):
            return e.localizedDescription
        case .unknown:
            return "Unknown error"
        }
    }
}
