//
//  KeychainManager.swift
//  PetFinder
//
//  Created by Iustin Bulimar on 19.10.2023.
//

import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    func set(_ value: String, forKey key: String) -> Bool {
        if let data = value.data(using: .utf8) {
            return set(data, forKey: key)
        }
        return false
    }
    
    func set(_ value: Data, forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: value
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func string(forKey key: String) -> String? {
        if let data = data(forKey: key),
           let currentString = String(data: data, encoding: .utf8) {
            return currentString
        }
        return nil
    }
    
    func data(forKey key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                return data
            }
        }
        return nil
    }
    
    func remove(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
