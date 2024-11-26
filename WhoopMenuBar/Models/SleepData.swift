//
//  SleepData.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import Foundation

class SleepData {
    let cycleCount: Int
    let awakeTime: Int
    let lightSleep: Int
    let remSleep: Int
    let deepSleep: Int   // Slow wave sleep
    
    let sleepNeeded: Int // Time in millisec // TODO: fetch other sleep_needed data
    let sleepDebt: Int

    let sleepPerformance: Int
    let sleepConsistency: Double
    let sleepEfficiency: Double

    init(cycleCount: Int, awakeTime: Int, lightSleep: Int, remSleep: Int, deepSleep: Int, sleepNeeded: Int, sleepDebt: Int, sleepPerformance: Int, sleepConsistency: Double, sleepEfficiency: Double) {
        // Sleep stages
        self.cycleCount = cycleCount
        self.awakeTime = awakeTime
        self.lightSleep = lightSleep
        self.remSleep = remSleep
        self.deepSleep = deepSleep
        
        // Sleep needed
        self.sleepNeeded = sleepNeeded
        self.sleepDebt = sleepDebt

        // General information
        self.sleepPerformance = sleepPerformance
        self.sleepConsistency = sleepConsistency
        self.sleepEfficiency = sleepEfficiency
    }
    
    func getSleepPerformance() -> Int {
        return self.sleepPerformance
    }
    
    func getSleepNeed() -> Double {
        return Double(sleepNeeded) / 3600000
    }
    
    func getSleepHours() -> Double  {
        let sleepSumMilli = lightSleep + remSleep + deepSleep
        return Double(sleepSumMilli) / 3600000
    }
    
    func getLightSleepPercentage() -> Double {
        /// Percentage of actual sleep that was Light Sleep
        let lightSleep = Double(self.lightSleep) / 3600000
        return lightSleep / self.getSleepHours() * Double(self.sleepPerformance)
    }
    
    func getRemSleepPercentage() -> Double {
        /// Percentage of actual sleep that was Rem Sleep
        let remSleep = Double(self.remSleep) / 3600000
        return remSleep / self.getSleepHours() * Double(self.sleepPerformance)
    }
    
    func getDeepSleepPercentage() -> Double {
        /// Percentage of actual sleep that was Deep Sleep
        let deepSleep = Double(self.deepSleep) / 3600000
        return deepSleep / self.getSleepHours() * Double(self.sleepPerformance)
    }
    
    func getSleepEfficiency() -> Int {
        return Int(self.sleepEfficiency)
    }
    
    func getSleepConsistency() -> Int {
        return Int(self.sleepConsistency)
    }
    
    func getLightSleep() -> Double {
        return Double(self.lightSleep) / 3600000
    }
    
    func getRemSleep() -> Double {
        return Double(self.remSleep) / 3600000
    }
    
    func getDeepSleep() -> Double {
        return Double(self.deepSleep) / 3600000
    }
    
    /// Get as text methods
    func getSleepAsText() -> String {
        let sleepHours = getSleepHours()
        let hoursPart = Int(sleepHours)
        let minutesPart = Int((sleepHours - Double(hoursPart)) * 60)
        return String(format: "%02d:%02d", hoursPart, minutesPart)
    }
    
    func getAwakeAsText() -> String {
        let awakeHours = Double(self.awakeTime) / 3600000
        let hoursPart = Int(awakeHours)
        let minutesPart = Int((awakeHours - Double(hoursPart)) * 60)
        if hoursPart == 0 {
            return String(format: "0:%02d", minutesPart)
        } else {
            return String(format: "%02d:%02d", hoursPart, minutesPart)
        }
    }
    
    func getSleepDebtAsText() -> String {
        return "1:03"
    }

}
