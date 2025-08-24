//
//  ToolbarView.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import SwiftUI

struct ToolbarView: View {
    
    @Binding var pickedLanguage: Country
    var onSettingsSelected: (SettingsMenuData) -> Void
    
    var body: some View {
        HStack {
            LanguagePickerView(picked: $pickedLanguage)
                .accessibilityLabel("Language Button")
                
            Spacer()
            
            SettingsPickerView { settingsPicked in
                switch settingsPicked {
                case .about:
                    onSettingsSelected(.about)
                }
            }
            .padding(.trailing, 12)
            .accessibilityLabel("Settings Menu Button")
            
            
        }.padding(.leading)
    }
}

#Preview {
    ToolbarView(pickedLanguage: .constant(.init(name: "", flag: "", code: ""))) { _ in
        
    }
}
