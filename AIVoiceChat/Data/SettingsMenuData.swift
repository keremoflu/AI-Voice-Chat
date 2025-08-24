//
//  SettingsMenuData.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import Foundation

enum SettingsMenuData: String, Identifiable {
    var id: String { self.rawValue }
    case about
    
    var title: String {
        switch self {
        case .about:
            return "About"
        }
    }
    
    var contentString: String {
        switch self {
        case .about:
            return "AI Voice Chat App created by Kerem Oflu"
        }
    }
    
    var systemImageName: String {
        switch self {
        case .about:
            return "info.circle.fill"
        }
    }
}
