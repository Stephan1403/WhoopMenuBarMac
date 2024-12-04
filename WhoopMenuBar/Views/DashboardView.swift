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
    
    @State private var showingInfo: Bool = false
    @State private var showingError: Bool = false

    init(authService: AuthService) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(authService: authService))
    }
  

    var body: some View {
        VStack {
            TopBar(viewModel: viewModel)
            
            Divider()
            
            if(viewModel.apiError != nil && !viewModel.allDataLoaded()) {
                Text("Error")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding(.bottom, 5)
                
                Text("Unable to load data. Check internet connection and try again. Otherwise logout and login again.") // TODO: add dynamic message
                    .font(.caption)
                    .multilineTextAlignment(.center)  // Optional for alignment
                    .lineLimit(nil)
                    .frame(width: 300)
                    
                Button(action: {
                    viewModel.refreshAll()
                }, label: {
                    HStack {
                        Text("Reload data")
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .frame(width: 10, height: 12, alignment: .center)
                    }
                })
                .padding()
                        
                
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

