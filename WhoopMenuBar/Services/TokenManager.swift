//
//  TokenManager.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 09.09.24.
//
enum KeychainError: Error {
    case duplicateEntry
    case unknown(OSStatus)
}

import Foundation

class TokenManager {
    static let shared = TokenManager()
    private init() {}
    
    
    private var accessToken = "whoopAccessToken"

    private var appIdentifier: String {
        return Bundle.main.bundleIdentifier ?? "com.whoopmenubar"
    }
    
    func getValidToken() async -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.appIdentifier,
            kSecAttrService as String: self.accessToken,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
            
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else {
            // TODO: handle
            return nil
        }
        
        if status == errSecSuccess, let data = item as? Data {
            do {    // TODO: add better error handling
                let authToken = try JSONDecoder().decode(AuthToken.self, from: data)
                
                if (Date() >= authToken.expiry) {
                    // Token is expired
                    if let refreshToken = authToken.refreshToken {
                        let newToken = try await self.refreshToken(refresh_token: refreshToken)
                        try self.storeAuthToken(for: newToken)
                        return newToken.accessToken
                    }
                }
                
                return authToken.accessToken
            } catch {
                print("Failed to decode auth token")
                return nil
            }
        } else {
            print("Failed to retrieve token with status \(status).")
            return nil
        }
    }
    
    public func storeAuthToken(for authToken: AuthToken) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.appIdentifier,
            kSecAttrService as String: self.accessToken,

        ]
        
        let changes: [String: Any] = [
            kSecValueData as String: try JSONEncoder().encode(authToken),
        ]
        
        let status = SecItemUpdate(query as CFDictionary, changes as CFDictionary)
        guard status != errSecItemNotFound else {
            // Create item if not exists
            try self.createAuthToken(for: authToken)
            return
        }
        guard status == errSecSuccess else {
            print("Keychain error, while trying to store auth token: \(status)")
            throw KeychainError.unknown(status)
        }
        
    }
    
    public func deleteAuthToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.appIdentifier,
            kSecAttrService as String: self.accessToken,
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            print("Keychain error, while trying to delete auth token: \(status)")
            throw KeychainError.unknown(status)
        }
    }
    
    private func createAuthToken(for authToken: AuthToken) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: self.appIdentifier,
            kSecAttrService as String: self.accessToken,
            kSecValueData as String: try JSONEncoder().encode(authToken),
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
    }
    
    
    
    private func refreshToken(refresh_token: String) async throws -> AuthToken {
        var request = URLRequest(url: getTokenRequestUrl())
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = getTokenRefreshBody(refresh_token: refresh_token)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Transform to httpResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthenticationError.invalidHTTPResponse((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        guard httpResponse.statusCode == 200 else {
            throw AuthenticationError.invalidHTTPResponse(httpResponse.statusCode)
        }
        
        do {
            // Create authRes from response
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                guard let access_token = jsonResponse["access_token"] as? String else {
                    throw AuthenticationError.invalidTokenResponse
                }
                let refresh_token = jsonResponse["refresh_token"] as? String    // Included when offline in scope

                let authToken = AuthToken(
                    accessToken: access_token,
                    expiry: Date().addingTimeInterval(jsonResponse["expires_in"] as? Double ?? 0),
                    refreshToken: refresh_token)
                
                return authToken
            }
            throw AuthenticationError.invalidTokenResponse
            
        } catch {
            throw AuthenticationError.tokenRequestFailed
        }
        
    }
    
    
}

