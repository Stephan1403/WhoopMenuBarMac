//
//  KeychainUtils.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 08.09.24.
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    private init() {}
    
    private var appIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.whoopmenubar"
    }
    
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
    }
    
    func storeToken(_ token: String, forKey key: String) throws {
        let fullKey = "\(appIdentifier).\(key)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: fullKey,
            kSecValueData as String: token,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        print("Added token probably \(status)")
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
            
    }
    
    func getToken(forKey key: String) -> String? {
        let fullKey = "\(appIdentifier).\(key)"
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: fullKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    
}


