//
//  SleepSectionView.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import SwiftUI
import Charts

struct SleepElement {
    var type: String
    var hours: Double
    var elementOpacity: Double
}


struct SleepSectionView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack {
             /// Sleep performance
            if viewModel.sleepData == nil {
                ProgressView()
                    .progressViewStyle(.circular)
            } else {
                let sleepPerformance = viewModel.sleepData!.getSleepPerformance()
                var performanceColor: Color {
                    sleepPerformance < 70 ? .red :
                    sleepPerformance < 85 ? .yellow :
                    .green
                }

                HStack {
                    Image(systemName: "gauge.with.dots.needle.33percent")
                        .foregroundStyle(performanceColor)
                    Text("\(sleepPerformance)% Sleep Performance")
                }
                .font(.headline)
                
                // Sleep Stages
                SleepStagesView(viewModel: viewModel)
                
                /// Sleep Data
                SleepDataView(viewModel: viewModel)
            }
            
        }
            
            
        .onAppear {
            viewModel.getSleepData()
        }
    }
}

