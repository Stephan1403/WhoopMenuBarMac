//
//  ReoveryData.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 08.09.24.
//

import Foundation

class RecoveryData {
    let score: Int
    let hrv: Double         // heart rate variablity
    let rHR: Int            // Resting heart rate
    let skinTemp: Double    // In celcius
    
    init(score: Int, hrv: Double, rHR: Int, skinTemp: Double) {
        self.score = score
        self.hrv = hrv
        self.rHR = rHR
        self.skinTemp = skinTemp
    }
    
    func getHrvAsText() -> String {
        return String(format: "%.0f", hrv)
    }
    
    func getRhrAsText() -> String {
        return String(rHR)
    }
    
    
}
