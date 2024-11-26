//
//  UrlUtils.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 06.09.24.
//

import Foundation


func getAuthUrl() -> URL {
    let redirectUri = "whoopmenubar://auth"
    let clientId = Bundle.main.infoDictionary!["WhoopClientId"] as! String

    var components = URLComponents()
    components.scheme = "https"
    components.host = "api.prod.whoop.com"
    components.path = "/oauth/oauth2/auth"
    
    // offline+read:cycles+read:recovery+read:sleep+read:workout+read:profile
    components.queryItems = [
        URLQueryItem(name: "client_id", value: clientId),
        URLQueryItem(name: "redirect_uri", value: redirectUri),
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope", value: "offline+read:cycles+read:recovery+read:sleep"),
        URLQueryItem(name: "state", value: "rndState"),
    ]
    
    return (components.url)!
}


func getTokenRequestUrl() -> URL {
    return URL(string: "https://api.prod.whoop.com/oauth/oauth2/token?grant_type=authorization_code")!;
}


func getTokenRequestBody(code: String) -> Data {
    let postData = [
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": "whoopmenubar://auth",
        "client_id": Bundle.main.infoDictionary!["WhoopClientId"] as! String,
        "client_secret": Bundle.main.infoDictionary!["WhoopClientSecret"] as! String,
    ]

    let postString = postData.map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    return postString.data(using: .utf8) ?? Data()
}


func getTokenRefreshBody(refresh_token: String) -> Data {
    let postData = [
        "grant_type": "refresh_token",
        "refresh_token": refresh_token,
        "client_id": Bundle.main.infoDictionary!["WhoopClientId"] as! String,
        "client_secret": Bundle.main.infoDictionary!["WhoopClientSecret"] as! String,
        "scope": "offline"
    ]
    
    let postString = postData.map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    
    return postString.data(using: .utf8) ?? Data()
}
