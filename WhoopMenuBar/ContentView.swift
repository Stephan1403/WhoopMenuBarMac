//
//  ContentView.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var authVm: AuthViewModel
    
    var body: some View {
        Group {
            if authVm.isAuthenticated {
                DashboardView(authService: authService)
            } else {
                LoginView()
            }
        }
    }
        
}

 #Preview {
     ContentView()
 }
