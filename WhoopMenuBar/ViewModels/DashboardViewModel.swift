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
    
    private var authService: AuthService
    private var whoopApi: WhoopApi
    
    init(authService: AuthService) {
        self.authService = authService
        self.whoopApi = WhoopApi(authService: authService)
    }
    
    
    func refreshAll() {
        // Reset data
        recoveryData = nil
        sleepData = nil
        
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
                return
            case .failure(let error):
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
                return
            case .failure(let error):
                /* TODO: check if data is up-to-date
                 // TODO: show Info button
                 if not add retry button
                 */
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
