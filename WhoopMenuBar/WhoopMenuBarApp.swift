//
//  WhoopMenuBarApp.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 02.09.24.
//

import SwiftUI

@main
struct WhoopMenuBarApp: App {
    @StateObject var authService = AuthService()    // Inject authService
    // Inject Icon state her
    
    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(authService)
                .environmentObject(AuthViewModel(authService: authService))
        } label: {
            let image: NSImage = {
                   let ratio = $0.size.height / $0.size.width
                   $0.size.height = 18
                   $0.size.width = 18 / ratio
                   return $0
               }(NSImage(named: "Logo")!)

               Image(nsImage: image)
            
            
        }
        .menuBarExtraStyle(.window)
    }
    

        
}

extension NSImage {
    /// Returns a tinted version of the image with the specified color.
    func tinted(with color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()
        color.set()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        imageRect.fill(using: .sourceAtop)
        
        image.unlockFocus()
        return image
    }
}
