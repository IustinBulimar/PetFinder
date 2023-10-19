//
//  AuthResponse.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import Foundation

struct AuthResponse: Codable {
    let tokenType: String
    let accessToken: String
    let expiresIn: TimeInterval
}
