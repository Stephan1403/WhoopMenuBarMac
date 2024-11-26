//
//  SleepDataView.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.10.24.
//

import SwiftUI

struct SleepDataView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        
        Grid (verticalSpacing: 25) {
            
            GridRow {
                /// Sleep Time
                let sleepTime = viewModel.sleepData?.getSleepAsText() ?? ""
                DataElement(value: "\(sleepTime)h", elementName: "Hours Of Sleep", iconName: "bed.double.fill", iconColor: .blue)

                Divider().frame(width: 50)
                
                /// Awake Time
                let awakeTime = viewModel.sleepData?.getAwakeAsText() ?? ""
                DataElement(value: "\(awakeTime)h", elementName: "Awake Time", iconName: "eye.fill", iconColor: .yellow)

            }
          
        }
        .padding()

       
        
    }
}
