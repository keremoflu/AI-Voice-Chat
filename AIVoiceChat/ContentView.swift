//
//  ContentView.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var alertManager = AlertManager()
    @StateObject var permissionManager: AudioPermissionManager
    @State var isShowSettingsAlert = false
    
    @State private var chatViews: [AnyView] = []
    
    init() {
        let alertManager = AlertManager()
        _alertManager = StateObject(wrappedValue: alertManager)
        _permissionManager = StateObject(wrappedValue: AudioPermissionManager(alertManager: alertManager))
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack {
                
                HStack {
                    LanguagePickerView(picked: .constant(Country(name: "Türkçe", flag: "🇹🇷", code: "tr-TR")))
                        
                    Spacer()
                }.padding(.leading)
                
                
                //Chat Bubbles
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(chatViews.indices, id: \.self) { item in
                            chatViews[item]
                        }
                    }.padding()
                }
                
                RecordButton(contentState: .constant(.readyToRecord))
                promptListView
            }
        }
        
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .onAppear {
//            permissionManager.startRequest { result in
//                switch result {
//                case .success( _):
//                    print("success")
//                case .failure(let failure):
//                    print("failure: \(failure.localizedDescription)")
//                }
//            }
//        }
        .onAppear {
            simulateChat(list: &chatViews)
        }
        .alert(item: $alertManager.alert) { alert in
            Alert(
                title: Text(alert.title),
                primaryButton: .cancel(),
                secondaryButton: .default(Text("Go To Settings"),
                action: alert.primaryAction))
        }
        
    }
}

//TODO: Remove This
private func simulateChat(list: inout [AnyView]) {
    list.append(
        AnyView(AIBubbleView())
    )
    
    list.append(
        AnyView(UserBubbleView(text: "Hello people this is my app!"))
    )
}

private var bubbleListView: some View {
    ScrollView {
        LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(0...20, id: \.self) { _ in
                AIBubbleView()
                UserBubbleView(text: "Deneme Text here")
            }
        }.padding()
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

/*
 ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        // Your dynamic Text items go here
                        ForEach(0..<10, id: \.self) { index in
                            Text("Item \(index + 1)")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.leading)  // Padding to avoid sticking to the edge
                }
 */
