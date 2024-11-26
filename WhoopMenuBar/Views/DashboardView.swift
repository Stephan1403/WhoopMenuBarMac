//
//  DashboardView.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel: DashboardViewModel
    @State private var networkMonitor = NetworkMonitor()
    
    // TODO: set global error
    
    @State private var showingInfo: Bool = false
    @State private var showingError: Bool = false

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(authService: authService))
    }
    
   /*
    @State private var connectedAndDataAvailable: Bool {
        print("Data loaded: \(viewModel.allDataLoaded())")
        print("Network connected: \(networkMonitor.isConnected)")
        return viewModel.allDataLoaded() || networkMonitor.isConnected
    }
    */

    var body: some View {
        VStack {
            TopBar(viewModel: viewModel)
            
            Divider()
            
            if(false) {
                Text("Missing Internet")
            } else {
                RecoverySectionView(viewModel: viewModel)
                    .padding()
                
                Divider()
                
                SleepSectionView(viewModel: viewModel)
                    .padding()
            }
        }
        .frame(width: 350)    // Sets width for all child components
        .background(
            LinearGradient( gradient: Gradient(colors: [
                 viewModel.recoveryColor.opacity(0.08),
                    .clear ]),
               startPoint: .top,
               endPoint: .bottom
              )
        )
        .edgesIgnoringSafeArea(.all)
        .padding(10)

    }
}

