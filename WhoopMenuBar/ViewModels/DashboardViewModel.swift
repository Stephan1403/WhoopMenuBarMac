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
    
    private var authService: AuthService
    private var whoopApi: WhoopApi
    
    
    init(authService: AuthService) {
        self.authService = authService
        self.whoopApi = WhoopApi(authService: authService)
        
        if let savedLastUpdate = UserDefaults.standard.object(forKey: "lastUpdate") as? Date {
            self.lastUpdate = savedLastUpdate
        } else {
            let newData = Date()
            UserDefaults.standard.set(newData, forKey: "lastUpdate")
            lastUpdate = newData
        }
    }
    
    
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
            switch (result) {
            case .success(let data):
                Task {
                    DispatchQueue.main.async {
                        self.recoveryData = data
                        self.setRecoveryColor()
                    }
                }
                Task {
                    DispatchQueue.main.async {
                        self.apiError = nil
                        self.lastUpdate = Date()
                    }
                }
                return
            case .failure(let error):
                // TODO: store correct error
                Task {
                    DispatchQueue.main.async { self.apiError = error.localizedDescription}
                }
                print("Unable to retrieve recovery data: \(error.localizedDescription)")
            }
        }
    }
    
    
    func getSleepData() {
        whoopApi.fetchSleepData { result in
            switch (result) {
            case .success(let data):
                Task {
                    DispatchQueue.main.async {
                        self.sleepData = data
                    }
                }
                Task {
                    DispatchQueue.main.async {
                        self.apiError = nil
                        self.lastUpdate = Date()
                    }
                }
                return
            case .failure(let error):
                /* TODO: check if data is up-to-date
                 // TODO: show Info button
                 if not add retry button
                 */
                Task {
                    DispatchQueue.main.async { self.apiError = error.localizedDescription}
                }
                print("Unable to retrieve sleep data: \(error.localizedDescription)")
            }
        }
    }

    
    
    
    
    
    func logout() throws {
        try self.authService.invalidate()
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
