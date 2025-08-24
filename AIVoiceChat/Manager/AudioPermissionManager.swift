//
//  AudioPermissionManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import Foundation
import AVFoundation

final class AudioPermissionManager: ObservableObject {
    
    @Published var permissonStatus: AVAudioSession.RecordPermission = .undetermined
    private let alertManager: AlertManager
    
    init(alertManager: AlertManager) {
        self.alertManager = alertManager
    }
    
    func startRequest(responseState: @escaping (Result<AVAudioSession.RecordPermission, AudioPermissionError>) -> Void) {
        
        let session = AVAudioSession.sharedInstance()
        let systemStatus = session.recordPermission
        
        switch systemStatus {
        case .undetermined:
            requestRecordPermission { [weak self] isGranted in
                guard let self else {
                    print("weak fail")
                    responseState(.failure(.disconnect))
                    return
                }
                
                let updatedStatus = self.getPermissionStatus()
                self.permissonStatus = updatedStatus
                self.handlePermissionStatus(updatedStatus, responseState: responseState)
                
            }
        default:
            handlePermissionStatus(systemStatus, responseState: responseState)
        }
    }
    
    private func handlePermissionStatus(_ status: AVAudioSession.RecordPermission, responseState: @escaping (Result<AVAudioSession.RecordPermission, AudioPermissionError>) -> Void) {
        switch status {
        case .undetermined:
            responseState(.failure(.unknown))
        case .denied:
            alertManager.showAlertContent(type: .audioPermission)
            responseState(.failure(.disabled))
        case .granted:
            responseState(.success(.granted))
        @unknown default:
            responseState(.failure(.unknown))
        }
    }
    
    
    func getPermissionStatus () -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }
    
    func requestRecordPermission(completionHandler: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] isGranted in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.permissonStatus = isGranted ? .granted : .denied
                completionHandler(isGranted)
            }
        }
    }
}

extension AudioPermissionManager {
    enum AudioPermissionError: Error, LocalizedError {
        case disabled
        case unknown
        case failedOpenSettings
        case showRequestFailed
        case disconnect
        
        var errorDescription: String? {
            switch self {
            case .disabled:
                return "Microphone Usage Permission is denied. If it's a mistake, please go settings and enable it."
            case .unknown:
                return "Unknown Permission State, please try again later."
            case .failedOpenSettings:
                return "We're failed to open settings. Please go settings and enable microphone permission."
            case .showRequestFailed:
                return "We've tried to show permission but failed. Please go settings and enable microphone permission."
            case .disconnect:
                return "We've lost disconnection with permissions. Please go settings and enable microphone permission"
            }
        }
    }
}
