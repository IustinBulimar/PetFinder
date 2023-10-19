//
//  AuthManager.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import Foundation

class AuthManager {
    static let shared = AuthManager()
    
    private var accessToken: String?
    private var expirationDate: Date?
    
    private let accessTokenKey = "accessToken"
    private let expirationDateKey = "expirationDate"
    
    private init() {
        reloadData()
    }
    
    func update(token: String, expiresIn: TimeInterval) {
        self.accessToken = token
        self.expirationDate = Date().addingTimeInterval(expiresIn)
        
        saveData()
    }
    
    var validAccessToken: String? {
        guard let accessToken = accessToken,
                let expirationDate = expirationDate,
              expirationDate > Date() else {
            return nil
        }
        return accessToken
    }
    
    func eraseData() {
        accessToken = nil
        expirationDate = nil
        
        UserDefaults.standard.removeObject(forKey: expirationDateKey)
        _ = KeychainManager.shared.remove(forKey: accessTokenKey)
    }
    
    func saveData() {
        if let accessToken, let expirationDate  {
            _ = KeychainManager.shared.set(accessToken, forKey: accessTokenKey)
            UserDefaults.standard.set(expirationDate, forKey: expirationDateKey)
        } else {
            eraseData()
        }
    }
    
    func reloadData() {
        accessToken = KeychainManager.shared.string(forKey: accessTokenKey) ?? nil
        expirationDate = UserDefaults.standard.object(forKey: expirationDateKey) as? Date ?? nil
    }
}

