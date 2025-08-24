//
//  ToastData.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import Foundation

enum ToastData {
    case networkFailed
    
    var toast: Toast {
        switch self {
        case .networkFailed:
            return Toast(message: "Network Connection Failed", systemImageName: "wifi.slash")
        }
    }
}
