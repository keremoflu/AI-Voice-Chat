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
                    
                    SettingsPickerView { settingsPicked in
                        print("settingsPicked: \(settingsPicked.rawValue)")
                    }.padding(.trailing, 12)
                    
                }.padding(.leading)
                
                
                //CHAT BUBBLE
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(chatViews.indices, id: \.self) { index in
                                chatViews[index]
                                    .id(index)
                            }
                        }.padding()
                    }
                    .onChange(of: chatViews.count) { _ in
                        if let last = chatViews.indices.last {
                            withAnimation {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }
                
                RecordButton(contentState: .constant(.readyToRecord))
                PromptView(didPromptSelected: { prompt in
                    chatViews.append(AnyView(AIBubbleView(text: prompt.text)))
                })
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
        AnyView(AIBubbleView(text: "Deneme People"))
    )
    
    list.append(
        AnyView(UserBubbleView(text: "Hello people this is my app!"))
    )
}

private struct PromptView: View {
    
    var didPromptSelected: (Prompt) -> Void
    
    var body: some View {
        VStack (alignment: .leading, spacing: 8) {
            Text("Ask Anything")
                .font(.quickSand(size: 16, name: .regular))
                .foregroundColor(.blackSecondary)
                .padding(.leading)
            PromptHorizontalListView { selectedPrompt in
                didPromptSelected(selectedPrompt)
            }
        }
        
    }
}

private struct SettingsButton: View {
    
    var onAction: () -> Void
    
    var body: some View {
        
        Button  {
            onAction()
        } label: {
            Image(systemName: "gearshape")
                .font(.system(size: 24, weight: .light))
        }
        .foregroundColor(.blackPrimary)
        .padding(.trailing, 8)
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
