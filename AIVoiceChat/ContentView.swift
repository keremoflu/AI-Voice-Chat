//
//  ContentView.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var permissionManager = AudioPermissionManager()
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack {
                
                HStack {
                    LanguagePickerView(picked: .constant(Country(name: "Türkçe", flag: "🇹🇷", code: "tr-TR")))
                        
                    Spacer()
                }.padding(.leading)
                Text("PERMISSION: \(permissionManager.permissonStatus.getStateMessage())")
                
                Spacer()
                promptListView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            permissionManager.startRequest { result in
                switch result {
                case .success(let success):
                    print("success")
                case .failure(let failure):
                    print("failure")
                }
            }
        }
        
    }
}

private var promptListView: some View {
    VStack (alignment: .leading, spacing: 8) {
        Text("Ask Anything")
            .font(.quickSand(size: 16, name: .regular))
            .foregroundColor(.blackSecondary)
            .padding(.leading)
        PromptHorizontalListView { selectedPrompt in }
    }
}

#Preview {
    ContentView()
}
