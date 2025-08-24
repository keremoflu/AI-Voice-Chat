//
//  SpeechPermissionManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation
import Speech

final class SpeechPermissionManager: ObservableObject {
    @Published var permissionStatus: SFSpeechRecognizerAuthorizationStatus
    private let alertManager: AlertManager
    typealias SpeechStatus = SFSpeechRecognizerAuthorizationStatus
    
    init(alertManager: AlertManager) {
        self.alertManager = alertManager
        self.permissionStatus = SFSpeechRecognizer.authorizationStatus()
    }
    
    var currentStatus: SpeechStatus { SFSpeechRecognizer.authorizationStatus() }
    
    func startRequest(responseState: @escaping (Result<SpeechStatus, SpeechPermissionError>) -> Void) {
        let status = currentStatus
        if status == .notDetermined {
            requestSpeechPermission { [weak self] newStatus in
                guard let self else {
                    responseState(.failure(.unknown))
                    return
                }
                self.permissionStatus = newStatus
                self.handlePermissionStatus(newStatus, responseState: responseState)
            }
        } else {
            permissionStatus = status
            handlePermissionStatus(status, responseState: responseState)
        }
    }
    
    func handlePermissionStatus(_ status: SpeechStatus, responseState: @escaping (Result<SpeechStatus, SpeechPermissionError>) -> Void) {
        switch status {
        case .notDetermined:
            responseState(.failure(.unknown))
        case .authorized:
            responseState(.success(.authorized))
        case .denied:
            alertManager.showAlertContent(type: .speechPermission)
            responseState(.failure(.denied))
        case .restricted:
            responseState(.failure(.restricted))
        @unknown default:
            responseState(.failure(.unknown))
        }
    }
    
    func requestSpeechPermission(completion: @escaping (SpeechStatus) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status)
            }
        }
    }
}

extension SpeechPermissionManager {
    enum SpeechPermissionError: Error, LocalizedError {
        case requestFailed
        case failedOpenSettings
        case denied
        case restricted
        case unknown
        case showRequestFailed
        case disconnect
        
        var errorDescription: String? {
            switch self {
            case .failedOpenSettings:
                return "We're failed to open settings. Please go settings and speech recognition permission."
            case .requestFailed:
                return "Starting Speech Permission Request Failed. Please Go Settings and Enable permission."
            case .denied:
                return "Required Speech Recognition was not allowed."
            case .restricted:
                return "Speech Recognition is restricted on this device. Please enable it and try again."
            case .unknown:
                return "Unknown Permission State, please try again later."
            case .showRequestFailed:
                return "We've tried to show permission but failed. Please go settings and enable speech recognition permission."
            case .disconnect:
                return "We've lost disconnection with permissions. Please go settings and enable speech recognition permission."
            }
        }
    }
}
