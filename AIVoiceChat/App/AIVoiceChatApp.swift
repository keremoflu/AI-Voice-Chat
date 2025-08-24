//
//  AIVoiceChatApp.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI

@main
struct AIVoiceChatApp: App {
    
    //TODO: Activate Again
    @StateObject private var networkManager = NetworkManager()
    let persistance = PersistanceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(networkManager: networkManager)
                .environmentObject(networkManager)
                .environment(\.managedObjectContext, persistance.container.viewContext)
        }
    }
}
