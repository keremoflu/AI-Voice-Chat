//
//  SettingsPickerView.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import SwiftUI

struct SettingsPickerView: View {
    
    enum SettingsSelection: String, CaseIterable {
        case about = "About"
        
        var systemIconName: String {
            switch self {
            case .about:
                return "info.circle"
            }
        }
    }
    
    var pickedSelection: (SettingsSelection) -> Void
    
    var body: some View {
        Menu {
            VStack {
                ForEach(SettingsSelection.allCases, id: \.self) { item in
                    Button {
                        pickedSelection(item)
                            
                    } label: {
                        Label(item.rawValue, systemImage: item.systemIconName)
                            .accessibilityLabel(Text("Settings \(item.rawValue) choice"))
                    }
                }
            }
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 24, weight: .light))
                .foregroundColor(.blackPrimary)
        }
    }
}

#Preview {
    SettingsPickerView(pickedSelection: {_ in })
}
