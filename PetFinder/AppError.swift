//
//  AppError.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import Foundation

enum AppError: LocalizedError {
    case generic
    case fileNotFound(fileName: String)
    case invalidCredentials
    case badRequest(statusCode: Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials"
        default:
            return "Something went wrong. Please try again."
        }
    }
}
