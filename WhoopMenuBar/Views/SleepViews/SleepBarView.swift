//
//  SleepBar.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 29.09.24.
//

struct SleepStage2 {
    let name: String
    let sleepHours: Double // Percentage of whole sleep
}

import SwiftUI
import Charts

struct SleepBarView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        VStack {
            let sleepPerformance = viewModel.sleepData!.getSleepPerformance()
            var performanceColor: Color {
                sleepPerformance < 70 ? .red :
                sleepPerformance < 85 ? .yellow :
                .green
            }
            
            let sleepStages = [
                SleepStage2(name: "LIGHT", sleepHours: viewModel.sleepData?.getLightSleepPercentage() ?? 0.0),
                SleepStage2(name: "REM", sleepHours: viewModel.sleepData?.getRemSleepPercentage() ?? 0.0),
                SleepStage2(name: "DEEP", sleepHours: viewModel.sleepData?.getDeepSleepPercentage() ?? 0.0)
            ]
            
            // Sleep performance
            HStack {
                Image(systemName: "gauge.with.dots.needle.33percent")
                    .foregroundStyle(performanceColor)
                Text("\(sleepPerformance)% Sleep Performance")
            }
            .font(.headline)

            
            // Sleep bar
            Chart {
                ForEach(sleepStages, id: \.name) { stage in
                    BarMark(
                        x: .value(stage.name, stage.sleepHours),
                        y: .value("Type", "Sleep stages"),
                        height: 15
                    )
                    .foregroundStyle(by: .value("Name", stage.name))
                }
                
                if sleepPerformance < 100 {
                    BarMark(
                        x: .value("Missing sleep", 100-sleepPerformance),
                        y: .value("Type", "Sleep stages"),
                        height: 15
                    )
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .opacity(0.2)
                }
                    
            
                RuleMark(
                    x: .value("Sleep needed", 100)
                )
                .lineStyle(StrokeStyle(lineWidth: 2))
                .foregroundStyle(.white)
                .annotation(position: .trailing) {
                    HStack {
                        Image(systemName: "bed.double.fill")
                            .foregroundStyle(.blue)
                            .padding(.trailing, -5)
                        Text("\(viewModel.sleepData!.getSleepAsText()) h")
                    }
                    .font(.caption)
                    .padding(.leading, 15)
                }
                
            }
            .chartYAxis(.hidden)
            .chartXAxis {
                AxisMarks (values: [0, 25, 50, 75, 100]){
                    AxisValueLabel()
                }
            }
            .frame(width: 300, height: 50)
            .padding(.vertical, 15)
            .padding(.bottom, 15)
                
            
        }
        .onAppear {
            viewModel.getSleepData()
        }

    }
}

