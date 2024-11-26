//
//  LoginView.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import SwiftUI


struct LoginView: View {
    @EnvironmentObject var authVm: AuthViewModel
    
    var body: some View {
        VStack(alignment: .center, spacing: 10){
            Text("Login to access your data")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 15)
            
            
            HStack(alignment: .top, spacing: 4) {
                Image(systemName: "info.circle")
                    .foregroundStyle(.blue)
                
                Text("This application needs access to your Whoop account to display your data. Your data will not be stored in any way.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray))
            )
            
            
            Button(action: {
                let window = NSApplication.shared.windows.first
                authVm.login(window: window)
            }, label: {
                Text("Authenticate Whoop")
                    .font(.body)
                    .foregroundStyle(.white)
            })
            .background(Color.blue)
            .cornerRadius(8)
            .padding(.top, 15)

        }.padding()
            .onAppear {
                if let window = NSApplication.shared.windows.first {
                    // Store window in authVM
                    authVm.presentationWindow = window
               }
            }
        
      
        
    }
}



#Preview {
    LoginView()
}
