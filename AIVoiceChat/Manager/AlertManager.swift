//
//  AlertManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation
import SwiftUI

final class AlertManager: ObservableObject{
    @Published var alert: AlertContent?
    
//    enum AlertType {
//        case goToSettings(title: String, message: String, primaryButtonText: String, onAction: () -> Void)
//        case infoMessage(title: String, message: String, primaryButtonText: String, onAction: () -> Void)
//    }
//    
//    func showAlert(for type: AlertType) {
//        switch type {
//        case .goToSettings(let title, let message, let primaryButtonText, let onAction):
//            alert = AlertContent(title: title, message: message, primaryButtonText: primaryButtonText, primaryAction: onAction)
//            
//        case .infoMessage(let title, let message, let primaryButtonText, let onAction):
//            alert = AlertContent(title: title, message: message, primaryButtonText: primaryButtonText, primaryAction: onAction)
//            
//        }
//    }
    
    enum AlertContentType {
        case emptyField
        case audioPermission
        case speechPermission
        case recordingFailed(Error)
        case inProgress
        case promptRequestFailed(Error)
        case transcriptionFailed(Error)
    }
    
    func showAlertContent(type: AlertContentType) {
        switch type {
        case .emptyField:
            alert = AlertContent(title: "No speech detected!", message: "Please record longer voice to detect speech", primaryButtonText: "OK", primaryAction: {})
        case .audioPermission:
            alert = AlertContent(title: "Microphone Permission Required!", message: "Please go settings and enable microphone permission", primaryButtonText: "Go To Settings", primaryAction: { [weak self] in
                guard let self else { return }
                openSettings()
            })
        case .speechPermission:
            alert = AlertContent(title: "Speech Permission Required!", message: "Please go settings and enable speech recognition permission", primaryButtonText: "Go To Settings", primaryAction: { [weak self] in
                guard let self else { return }
                openSettings()
            })
            
        case .recordingFailed (let error):
            alert = AlertContent(title: "Recording Failed", message: "Error: \(error.localizedDescription)", primaryButtonText: "OK", primaryAction: {})
            
        case .inProgress:
            alert = AlertContent(title: "Please wait...", message: "Record is still in progres.", primaryButtonText: "OK", primaryAction: {})
            
        case .promptRequestFailed(let error):
            alert = AlertContent(title: "We're failed trying prompt.", message: "Error: \(error.localizedDescription)", primaryButtonText: "OK", primaryAction: {})
            
        case .transcriptionFailed(let error):
            alert = AlertContent(title: "Transcription Failed", message: "Please try new recording. Error: \(error.localizedDescription)", primaryButtonText: "OK", primaryAction: {})
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
