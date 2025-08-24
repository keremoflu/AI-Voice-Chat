//
//  SettingsURLHandler.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import Foundation
import SwiftUI

struct SettingsURLHandler {
    
    static func openAppSettings() {
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        guard UIApplication.shared.canOpenURL(url) else {
           return
        }
        
        UIApplication.shared.open(url)
    }
}
