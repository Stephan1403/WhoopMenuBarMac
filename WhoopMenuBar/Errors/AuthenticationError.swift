//
//  AuthenticationError.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 10.10.24.
//

import Foundation

enum AuthenticationError: Error, LocalizedError {
    case authenticationFailed(String)
    case callbackURLMissing
    case invalidAuthorizationCode
    
    case invalidTokenResponse
    case tokenRequestFailed
    
    case invalidHTTPResponse(Int)
    
    case keychainError(String)
    
    var errorDescription: String? {
        switch self {
        case .authenticationFailed(let reason):
            return "Authentication failed: \(reason)"
        case .callbackURLMissing:
            return "The callback URL is missing or invalid"
        case .invalidAuthorizationCode:
            return "Authorization code is missing or invalid"
        case .invalidTokenResponse:
            return "The token response from the server was invalid"
        case .tokenRequestFailed:
            return "Failed to obtain the access token from the token request."
        case .invalidHTTPResponse(let statusCode):
            return "Received an invalid HTTP response. Status code: \(statusCode)"
        case .keychainError(let reason):
            return "Failed to store token in keychain: \(reason)"
        }
    }
    
}
