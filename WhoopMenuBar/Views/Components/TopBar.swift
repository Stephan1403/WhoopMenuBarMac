//
//  TopBar.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 25.11.24.
//

import SwiftUI

struct TopBar: View {
    @ObservedObject var viewModel: DashboardViewModel

    @State private var showingInfo: Bool = false
    @State private var showingSettings: Bool = false
    @State private var logoutError: Bool = false
    
    @State private var mayOutdated: Bool = false

    var body: some View {
        HStack {
            Button( action: {
                showingInfo.toggle()
            }) {
                if (viewModel.isUpToDate) {
                    Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
                        .resizable()
                        .foregroundStyle(.green)
                        .frame(width: 15, height: 17, alignment: .center)
                        .padding(.bottom, 2.5)
                } else {
                    Image(systemName: "info.circle")
                        .resizable()
                        .foregroundStyle(.red)
                        .frame(width: 15, height: 15, alignment: .center)
                }
                
            }
            .buttonStyle(.plain)
            .frame(width: 50)
            /// Popover
            .popover(isPresented: $showingInfo) {
                
                // Check if update less than four hours ago
                if (viewModel.isUpToDate) {
                    UpToDatePopUp(viewModel: viewModel)
                } else {
                    OutdatedPopUp(viewModel: viewModel)
                }
            }
            
            
            Spacer()
            Text("Whoop")
                .font(.title3)
                .bold()
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .center) // Center-align the title
            Spacer()
            
            /// Settings
            
            Menu {
                // Reload data
                Button("Reload data") {
                    viewModel.refreshAll()
                }
                
                // Logout
                Button("Logout") {
                    do {
                        try viewModel.logout()
                    } catch {
                        logoutError = true
                    }
                }
                .alert("Unable to logout", isPresented: $logoutError) {
                     Button("OK", role: .cancel) {
                         logoutError = false
                     }
                }
                
                // Quit application
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .foregroundStyle(.red)
            } label: {
                Image(systemName: "gear")
            }
            .frame(width: 50)
            .padding(.trailing, 4)

        }
    }
}

