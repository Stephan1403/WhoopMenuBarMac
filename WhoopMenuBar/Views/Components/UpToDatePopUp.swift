//
//  UpToDatePopUp.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.12.24.
//

import SwiftUI

struct UpToDatePopUp: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Data is up to date")
                .font(.title3)
                .foregroundStyle(.green)
                .padding(.bottom, -5)
            
            if let time = viewModel.getLastUpdateTime() {
                Text("Last update: \(time)")
                    .font(.subheadline)
                    .padding(.bottom, 5)
            }
            
            Button(action: {
                viewModel.refreshAll()
            }) {
                HStack {
                    Text("Refresh")
                        .font(.body)
                    Image(systemName: "arrow.clockwise")
                        .padding(2)
                        .font(.body)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
        }
        .padding()
        .frame(width: 250, alignment: .leading)
    }
}
