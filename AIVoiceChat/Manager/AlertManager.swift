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
        case goToSettings(title: String, message: String, onAction: () -> Void)
    }
    
    func showAlert(for type: AlertType) {
        switch type {
        case .goToSettings(let title, let message, let onAction):
            alert = AlertContent(title: title, message: message, primaryAction: onAction)
        }
    }
}
