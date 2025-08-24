//
//  AboutSheet.swift
//  AIVoiceChat
//
//  Created by Kerem on 23.08.2025.
//

import SwiftUI

struct AboutSheet: View {
    
    var settingsMenuData: SettingsMenuData
    
    var body: some View {
        VStack (spacing: 32) {
            Image(settingsMenuData.systemImageName)
                .font(.system(size: 32))
            
            Text(settingsMenuData.title)
                .font(.quickSand(size: 24, name: .medium))
            
            Text(settingsMenuData.contentString)
                .font(.quickSand(size: 16, name: .regular))
        }
    }
}

#Preview {
    AboutSheet(settingsMenuData: .about)
}
