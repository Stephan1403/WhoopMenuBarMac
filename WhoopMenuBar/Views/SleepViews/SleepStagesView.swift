//
//  SleepStagesView.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 04.10.24.
//

import SwiftUI
import Charts


struct SleepStage {
    let name: String
    let sleepHours: Double
}

struct SleepStagesView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    @State private var selectedStage: String?
    
    func getSleepText(from hours: Double) -> String {
        let hoursPart = Int(hours)
        let minutesPart = Int((hours - Double(hoursPart)) * 60)
        return String(format: "%02d:%02d", hoursPart, minutesPart)
    }
    
    
    
    var body: some View {
        let sleepStages = [
            SleepStage(name: "LIGHT", sleepHours: viewModel.sleepData?.getLightSleep() ?? 0.0),
            SleepStage(name: "REM", sleepHours: viewModel.sleepData?.getRemSleep() ?? 0.0),
            SleepStage(name: "DEEP", sleepHours: viewModel.sleepData?.getDeepSleep() ?? 0.0)
        ]
        
        Chart {
            ForEach(sleepStages, id: \.name) { stage in
                BarMark(
                    x: .value(stage.name, stage.sleepHours),
                    y: .value("Type", "Sleep stages"),
                    height: stage.name == selectedStage ? 17 : 15
                )
                .cornerRadius(2)
                .foregroundStyle(by: .value("Name", stage.name))
                .annotation(position: .top) {
                    if (selectedStage == stage.name) {
                        VStack {
                            Text("\(getSleepText(from: stage.sleepHours))h")
                                .padding(4)
                                .font(.caption)
                                .background(Color(.darkGray))
                                .cornerRadius(4)
                                .shadow(radius: 2)
                        
                            Image(systemName: "arrowtriangle.down.fill")
                               .foregroundStyle(Color(.darkGray))
                               .padding(.top, -13)
                        }
                        .offset(y: 4)
                        
                    }
                }
            }
            
        }
        .chartOverlay { (proxy: ChartProxy) in
            Rectangle()
                //.fill(Color.orange.opacity(0.1))
                .fill(.clear)
                .frame(height: 22)
                .offset(y: -9)  // TODO: not detecting at top
                .onContinuousHover { hoverPhase in
                    switch hoverPhase {
                    case .active(let hoverLocation):
                            
                        if let proxyValue: Double = proxy.value(atX: hoverLocation.x, as: Double.self) {
                            // TODO: make more perforamnt
                            var stageEndValue: Double = 0
                            for stage in sleepStages {
                                stageEndValue += stage.sleepHours
                                if (proxyValue <= stageEndValue) {
                                    selectedStage = stage.name
                                    return
                                }
                            }

                        }
                        selectedStage = nil
                    case .ended:
                        selectedStage = nil
                    }
                    
                }
            
                    
            
        }
        .frame(height: 40)
        .padding(.vertical, 10)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}
