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
    @StateObject var chatVM = ChatViewModel()
    
    @State var isShowSettingsAlert = false
    @State var pickedLanguage = UserDefaultsManager.shared.speechCountry
    
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
                    LanguagePickerView(picked: $pickedLanguage)
                        
                    Spacer()
                    
                    SettingsPickerView { settingsPicked in
                        print("settingsPicked: \(settingsPicked.rawValue)")
                    }.padding(.trailing, 12)
                    
                }.padding(.leading)
                
                
                //CHAT BUBBLE
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(chatVM.messages, id: \.self) { message in
                                HStack {
                                    if message.sender == .ai {
                                        AIBubbleView(text: message.text)
                                        Spacer()
                                    } else {
                                        Spacer()
                                        UserBubbleView(text: message.text)
                                    }
                                }
                            }
                        }.padding()
                    }
                    .onChange(of: chatVM.messages.count) { _ in
                        if let last = chatVM.messages.indices.last {
                            withAnimation {
                                proxy.scrollTo(last, anchor: .bottom)
                            }
                        }
                    }
                }
                
                RecordButton(contentState: .constant(.readyToRecord))
                PromptView(didPromptSelected: { prompt in
                    chatVM.messages.append(Message(sender: .ai, text: prompt.text))
                })
            }
        }
        
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            permissionManager.startRequest { result in
                switch result {
                case .success( _):
                    print("permission success")
                case .failure(let failure):
                    print("failure: \(failure.localizedDescription)")
                }
            }
        }
        .onAppear {
            chatVM.simulateChat()
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
        .environmentObject(NetworkManager())
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
