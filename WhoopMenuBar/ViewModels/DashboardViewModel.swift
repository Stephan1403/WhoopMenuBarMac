//
//  DashboardViewModel.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

import Foundation
import SwiftUICore

class DashboardViewModel: ObservableObject {
    @Published var recoveryData: RecoveryData?
    @Published var sleepData: SleepData?
    
    @Published var recoveryColor: Color = .clear
    
    @Published var apiError: String? = nil
    @Published var lastUpdate: Date? {
        didSet {
            UserDefaults.standard.set(lastUpdate, forKey: "lastUpdate")
        }
    }
    @Published var isUpToDate: Bool = false // This checks if the data is older than a set time
    
    
    private var authService: AuthService
    private var whoopApi: WhoopApi
    
    
    init(authService: AuthService) {
        self.authService = authService
        self.whoopApi = WhoopApi(authService: authService)
        
        if let savedLastUpdate = UserDefaults.standard.object(forKey: "lastUpdate") as? Date {
            self.lastUpdate = savedLastUpdate
        } else {
            let now = Date()
            UserDefaults.standard.set(now, forKey: "lastUpdate")
            lastUpdate = now
        }
        
    }
    
    func updateLastUpdate() {
        Task {
            DispatchQueue.main.async { self.lastUpdate = Date() }

            // Check if data is up to date
            let fourHoursAgo = Calendar.current.date(byAdding: .hour, value: -4, to: Date())!   // TODO: update condition (make dependent on cycles??)
            if let time = self.lastUpdate, time > fourHoursAgo, self.apiError == nil {
                DispatchQueue.main.async { self.isUpToDate = true }
            } else {
                DispatchQueue.main.async { self.isUpToDate = false }
            }
        }
    }
    
    
    /// API Interaction
    func refreshAll() {
        recoveryData = nil // TODO: remove these and add loading animation instead
        sleepData = nil

        // Reset color
        if self.recoveryData == nil {
            self.recoveryColor = .clear
        }
        
        // Load data
        self.getRecoveryData()
        self.getSleepData()
    }
    
    
    func allDataLoaded() -> Bool {
        recoveryData != nil && sleepData != nil
    }
    
    
    func getRecoveryData() {
        whoopApi.fetchRecoveryData { result in
            Task {
                switch (result) {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.recoveryData = data
                        self.setRecoveryColor()
                        self.apiError = nil
                    }
                    break
                case .failure(let error):
                    // TODO: store correct error
                    DispatchQueue.main.async { self.apiError = error.localizedDescription}
                    print("Unable to retrieve recovery data: \(error.localizedDescription)")
                    break
                }
                DispatchQueue.main.async { self.updateLastUpdate() }
            }
        }
    }
    
    
    func getSleepData() {
        whoopApi.fetchSleepData { result in
            Task {
                switch (result) {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.sleepData = data
                        self.apiError = nil
                    }
                    break
                case .failure(let error):
                    // TODO: store correct error
                    DispatchQueue.main.async { self.apiError = error.localizedDescription}
                    print("Unable to retrieve sleep data: \(error.localizedDescription)")
                    break
                }
                DispatchQueue.main.async { self.updateLastUpdate() }
            }
        }
    }
    
    
    func logout() throws {
        try self.authService.invalidate()
    }
    
    
    /// Other methods
    func getLastUpdateTime() -> String? {
        guard let lastUpdate = self.lastUpdate else { return nil }
        
        // Today
        if (Calendar.current.isDateInToday(lastUpdate)) {
            return lastUpdate.formatted(.dateTime.hour().minute())
        }
        if (Calendar.current.isDateInYesterday(lastUpdate)) {
            return "Yesterday at \(lastUpdate.formatted(.dateTime.hour().minute()))"
        }
        return lastUpdate.formatted()
    }
    
    
    private func setRecoveryColor() {
        guard let score = self.recoveryData?.score else {
            self.recoveryColor = .clear
            return
        }
        
        switch(score) {
        case 0...33:
            self.recoveryColor = .red
        case 34...66:
            self.recoveryColor = .yellow
        case 67...100:
            self.recoveryColor = .green
        default:
            self.recoveryColor = .clear
        }
    }
    
    
    
}
