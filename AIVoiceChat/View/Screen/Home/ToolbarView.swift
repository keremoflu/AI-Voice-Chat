//
//  ToolbarView.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import SwiftUI

struct ToolbarView: View {
    
    var onSettingsSelected: (SettingsMenuData) -> Void
    @State var country: Country = UserDefaultsManager.shared.speechCountry
    
    var body: some View {
        HStack {
            LanguagePickerView(picked: $country)
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
    ToolbarView() { _ in
        
    }
}
