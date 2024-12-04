//
//  UpdateBox.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.12.24.
//

import SwiftUI

struct OutdatedPopUp: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Data may be outdated")
                .font(.title3)
                .foregroundStyle(.orange)
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
            
            
            Text("The last refresh was either unsuccessful or the data has beeen updated a long time ago. Refresh to ensure you see the most recent data.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
        }
        .padding()
        .frame(width: 250, alignment: .leading)
    }
}
