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
    @State private var showingError: Bool = false

    var body: some View {
        HStack {
            Button( action: {
                showingInfo.toggle()
            }) {
                if(false) {
                    Image(systemName: "info.circle")
                        .resizable()
                        .foregroundStyle(.red)
                        .frame(width: 15, height: 15, alignment: .center)
                } else {
                    Image(systemName: "checkmark.arrow.trianglehead.counterclockwise")
                        .resizable()
                        .foregroundStyle(.green)
                        .frame(width: 15, height: 17, alignment: .center)
                        .padding(.bottom, 2.5)
                }
                
            }
            .buttonStyle(.plain)
            .frame(width: 50)
            /// Popover
            .popover(isPresented: $showingInfo) {
                // TODO: fix logic and style
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Data may not be up to date.")
                            .font(.headline)
                        Spacer()
                        Button(action: {
                            print("Refresh")
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .padding(2)
                                .font(.body)
                        }
                    }
                    Text("Please note that the data you are viewing may not be the most recent. Refresh the data to ensure it's current.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                }
                .padding()
                .frame(width: 250)
            }
            
            
            Spacer()
            Text("Whoop")
                .font(.title3)
                .bold()
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .center) // Center-align the title
            Spacer()
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
                        showingError = true
                    }
                }
                .alert("Unable to logout", isPresented: $showingError) {
                     Button("OK", role: .cancel) {
                         showingError = false
                     }
                }
                
                // Quit application
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .foregroundStyle(.red)
            } label: {
                
                Image(systemName: "gearshape")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .padding(.top, 10)
            }
            .frame(width: 50)
            .padding(.trailing, 4)

        }
    }
}

