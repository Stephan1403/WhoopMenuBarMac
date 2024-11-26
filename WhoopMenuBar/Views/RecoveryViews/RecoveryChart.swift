//
//  RecoveryChart.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.10.24.
//

import SwiftUI
import Charts

struct RecoveryChart: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        
        if viewModel.recoveryData == nil {
            ProgressView()
                .scaleEffect(0.7)
                .progressViewStyle(.linear)
        } else {
            let recoveryScore = viewModel.recoveryData!.score
        
            VStack {
                Chart {
                    SectorMark(
                        angle: .value("Recovery", recoveryScore),
                        innerRadius: .ratio(0.8)
                    )
                    .foregroundStyle(viewModel.recoveryColor)
                    
                    SectorMark(
                        angle: .value("", 100 - recoveryScore),
                        innerRadius: .ratio(0.8)
                    )
                    .foregroundStyle(.background)
                        
                }
                .chartBackground { chartProxy in
                    GeometryReader { geometry in
                        let frame = geometry[chartProxy.plotFrame!]
                        VStack {
                            Text(String(recoveryScore))
                                .font(.largeTitle)
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                }
                .frame(width: 65, height: 65)
                    
                Text("Recovery")
                    .bold()
            }
            .frame(maxWidth: .infinity)
        
        }

    }
}

