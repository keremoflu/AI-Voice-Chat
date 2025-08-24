//
//  AIVoiceChatApp.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI

@main
struct AIVoiceChatApp: App {
    
    @StateObject private var networkManager = NetworkManager()
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(networkManager)
        }
    }
}
