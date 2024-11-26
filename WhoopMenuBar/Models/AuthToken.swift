//
//  AuthResponse.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import Foundation

struct AuthToken: Codable {
    let accessToken: String
    let expiry: Date
    let refreshToken: String?
}
