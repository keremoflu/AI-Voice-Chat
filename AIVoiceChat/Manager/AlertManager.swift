//
//  AlertManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

final class AlertManager: ObservableObject{
    @Published var alert: AlertContent?
    
    enum AlertType {
        case goToSettings(title: String, message: String, primaryButtonText: String, onAction: () -> Void)
        case infoMessage(title: String, message: String, primaryButtonText: String, onAction: () -> Void)
    }
    
    func showAlert(for type: AlertType) {
        switch type {
        case .goToSettings(let title, let message, let primaryButtonText, let onAction):
            alert = AlertContent(title: title, message: message, primaryButtonText: primaryButtonText, primaryAction: onAction)
            
        case .infoMessage(let title, let message, let primaryButtonText, let onAction):
            alert = AlertContent(title: title, message: message, primaryButtonText: primaryButtonText, primaryAction: onAction)
        }
    }
}
