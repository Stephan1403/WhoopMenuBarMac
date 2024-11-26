//
//  WhoopApi.swift
//  WhoopMenuBar
//
//  Created by Stephan Fussenegger on 03.09.24.
//

enum APIError: Error {
    case failedRequest
    case failedAuthentication
    case missingAccessToken
    case invalidResponse
    case invalidAuthorization
    case invalidData
}

import Foundation

class WhoopApi {
    private var authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    
    func fetchRecoveryData(completion: @escaping (Result<RecoveryData, APIError>) -> Void) {
        let url = "/v1/recovery"
        self.fetchData(from: url) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let records = jsonResponse?["records"] as? [[String: Any]], !records.isEmpty {
                        let recentCycle = records[0]
                        
                        // Access score
                        if let score = recentCycle["score"] as? [String: Any] {
                            
                            let recoveryData = RecoveryData(
                                score:      score["recovery_score"]     as? Int    ?? 0, // TODO: error message?
                                hrv:        score["hrv_rmssd_milli"]    as? Double ?? 0.0,
                                rHR:        score["resting_heart_rate"] as? Int    ?? 0,
                                skinTemp:   score["skin_temp_celsius"]  as? Double ?? 0.0
                            )
                            
                            completion(.success(recoveryData))
                            return
                        }
                        
                        
                    }
                    completion(.failure(.invalidData))
                    return
                } catch {
                    completion(.failure(.invalidResponse))
                    return
                }
                    
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
        
    }
    
    
    func fetchSleepData(completion: @escaping (Result<SleepData, APIError>) -> Void) {
        let url = "/v1/activity/sleep"  // TODO: first get cycle then get sleep by id
        self.fetchData(from: url) { result in
            switch result {
            case .success(let data):
                do {
                    let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    if let records = jsonResponse?["records"] as? [[String: Any]], !records.isEmpty {
                        let recentCycle = records[0]
                        
                        // Access score
                        if let cycle = recentCycle["score"] as? [String: Any] {
                            guard let sleepNeeded = cycle["sleep_needed"] as? [String: Any], let stageSummary = cycle["stage_summary"] as? [String: Any] else {
                                completion(.failure(.invalidData))
                                return
                            }
                        
                            let sleepData = SleepData (
                                cycleCount:         stageSummary["sleep_cycle_count"]                as? Int    ?? 0,
                                awakeTime:          stageSummary["total_awake_time_milli"]           as? Int    ?? 0,
                                lightSleep:         stageSummary["total_light_sleep_time_milli"]     as? Int    ?? 0,
                                remSleep:           stageSummary["total_rem_sleep_time_milli"]       as? Int    ?? 0,
                                deepSleep:          stageSummary["total_slow_wave_sleep_time_milli"] as? Int    ?? 0,
                                
                                sleepNeeded:        sleepNeeded["baseline_milli"]                    as? Int    ?? 0,
                                sleepDebt:          sleepNeeded["need_from_sleep_debt_milli"]        as? Int    ?? 0,
                                
                                sleepPerformance:   cycle["sleep_performance_percentage"]            as? Int    ?? 0,
                                sleepConsistency:   cycle["sleep_consistency_percentage"]            as? Double ?? 0,
                                sleepEfficiency:    cycle["sleep_efficiency_percentage"]             as? Double ?? 0
                            )
                            
                            completion(.success(sleepData))
                            return
                        }
                        
                    }
                    completion(.failure(.invalidData))
                    return
                } catch {
                    completion(.failure(.invalidResponse))
                    return
                }
                    
            case .failure(let error):
                completion(.failure(error))
                return
            }
        }
        
    }
    
    
    
    private func fetchData(from endpoint: String, completion: @escaping (Result<Data, APIError>) -> Void) {
        // Fetch data or fail
        // TODO: clean up
        let baseUrl = "https://api.prod.whoop.com/developer"    // TODO: get from env or so
        guard let url = URL(string: baseUrl + endpoint) else {
            completion(.failure(.failedRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Set authentication, show login if fails
        guard let token = authService.getValidToken() else {
            // TODO: show error
            completion(.failure(.missingAccessToken))
            return
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if (error != nil) {
                completion(.failure(.failedRequest))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                break
            case 401:
                // TODO: update token
                // TODO: or unauthorize
                print("Token is invalid: \(token)")
                completion(.failure(.invalidAuthorization))
                return
            default:
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(data))
        }
        
        task.resume()
    }
    
}
