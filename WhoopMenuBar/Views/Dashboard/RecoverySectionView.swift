//
//  RecoverySectionView.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 25.09.24.
//

import SwiftUI
import Charts

struct RecoverySectionView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack {
            if viewModel.recoveryData == nil {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                HStack (alignment: .top) {
                    DataElement(value: viewModel.recoveryData!.getHrvAsText(), elementName: "HRV", iconName: "waveform.path.ecg", iconColor: .blue) 
                        .frame(width: 60)
                        .padding(.top, 12)
                    VStack { Divider().frame(height: 78) }
                    RecoveryChart(viewModel: viewModel)
                    VStack { Divider().frame(height: 78) }
                    DataElement(value: viewModel.recoveryData!.getRhrAsText(), elementName: "RHR", iconName: "heart.fill", iconColor: .red)
                        .frame(width: 60)
                        .padding(.top, 12)
                }
            }
        }

        .onAppear {
            viewModel.getRecoveryData()
        }
        
        

            
    }
}

