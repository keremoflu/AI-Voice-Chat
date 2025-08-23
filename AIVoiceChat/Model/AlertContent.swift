//
//  AlertContent.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import Foundation

struct AlertContent: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let primaryButtonText: String
    let primaryAction: () -> Void
}
