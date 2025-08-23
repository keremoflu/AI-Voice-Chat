//
//  AlertTestHandler.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation

class AlertTestHandler: ObservableObject {
    @Published var isAlertHandlerShowing: Bool = false
    @Published var currentAlert: AlertContent?
    
    enum AlertType {
        case goToSettings(title: String, message: String, primaryButtonText: String, onAction: () -> Void)
    }
    
    func showAlert(for type: AlertType) {
        switch type {
        case .goToSettings(let title, let message, let primaryButtonText, let onAction):
            currentAlert = AlertContent(title: title, message: message, primaryButtonText: primaryButtonText, primaryAction: onAction)
            
        }
    }
}
