//
//  AuthService.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import Foundation
import Combine
import AuthenticationServices

// Handles authentication across all views
class AuthService: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
    init() {
        self.checkAuthentication()
    }
    
    func checkAuthentication() {
        Task {
            if (await TokenManager.shared.getValidToken() == nil) {
                DispatchQueue.main.async { self.isAuthenticated = false }
                return
            } else {
                DispatchQueue.main.async { self.isAuthenticated = true }
                return
            }
        }
    }
    
    func authenticate(context: ASWebAuthenticationPresentationContextProviding) async throws {
        // Start authentication, store token and return it
        
        return try await withCheckedThrowingContinuation { continuation in
            let scheme = "whoopmenubar" // TODO: Get from env
            let session = ASWebAuthenticationSession(url: getAuthUrl(), callbackURLScheme: scheme) { callback, error in
                if let error = error {
                    continuation.resume(throwing: AuthenticationError.authenticationFailed(error.localizedDescription))
                    return
                }
                
                // Handle callback
                Task {
                    do {
                        let token = try await self.exchangeCodeForToken(callback: callback)
                        try TokenManager.shared.storeAuthToken(for: token)
                        Task {
                            DispatchQueue.main.async { self.isAuthenticated = true }
                        }
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
                
            }
            session.presentationContextProvider = context
            session.start()
        }
        
    }
    
    func invalidate() throws {
        // Logout the user
        try TokenManager.shared.deleteAuthToken()
        Task {
            DispatchQueue.main.async { self.isAuthenticated = false }
        }
    }
    
    func getValidToken() -> String?  {
        let semaphore = DispatchSemaphore(value: 0)
        var accessToken: String? = nil
        
        Task {
            accessToken = await TokenManager.shared.getValidToken()
            semaphore.signal()
        }
        
        semaphore.wait()
        return accessToken
    }
    
    private func exchangeCodeForToken(callback: URL?) async throws -> AuthToken {
        guard let url = URLComponents(url: callback!, resolvingAgainstBaseURL: false) else {
            throw AuthenticationError.callbackURLMissing
        }
        guard let code = url.queryItems?.first(where: {$0.name == "code"})?.value else {
            throw AuthenticationError.invalidAuthorizationCode
        }
        
        var request = URLRequest(url: getTokenRequestUrl())
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = getTokenRequestBody(code: code)
        
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

