//
//  AuthViewModel.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import Foundation
import AuthenticationServices

class AuthViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    @Published var errorMessage: String? = nil
    var presentationWindow: NSWindow?
    
    // Authentication
    @Published var isAuthenticated: Bool
    private let tokenKey = "accessToken"

    private var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
        self.isAuthenticated = authService.isAuthenticated
        super.init()
        self.authService.$isAuthenticated.assign(to: &$isAuthenticated) // Sync authService with viewModel
    }
    
    
    func login(window: NSWindow?) {
        // Authenticating a user (requires current NSwindow)
        self.presentationWindow = window
        Task {
            do {
                try await authService.authenticate(context: self)
            } catch {
                print("Login failed: \(error.localizedDescription)")
                DispatchQueue.main.async { self.errorMessage = "Login failed: \(error.localizedDescription)" }
            }
        }
    }
    
    
    func logout() throws {
        try self.authService.invalidate()
    }
    
    
    // Conform to ASWebAuthenticationPresentationContextProviding
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard let window = presentationWindow else {
            fatalError("Presentation window is not set.")
            // FIX: Error when logout and then login
        }
        return window
        
    }
    
    
}
