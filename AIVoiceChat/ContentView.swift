//
//  ContentView.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var audioPlayer: AVAudioPlayer?
    
    @StateObject var chatVM = ChatViewModel()
    @StateObject private var alertManager = AlertManager()
    
    @State var isAboutSheetVisible = false
    @State var pickedLanguage = UserDefaultsManager.shared.speechCountry
    @State var activeSettingsSheet: SettingsMenuData? = nil
  
    init() {
       let alertManager = AlertManager()
       _alertManager = StateObject(wrappedValue: alertManager)
       _chatVM = StateObject(wrappedValue: ChatViewModel(alertManager: alertManager))
    }
    
    var body: some View {
        ZStack {
           
            Color.background
                .ignoresSafeArea()
            
            VStack {
                //LANGUAGE PICKER, SETTINGS
                ToolbarView(pickedLanguage: $pickedLanguage) { selection in
                    activeSettingsSheet = selection
                }
                
                //CHAT BUBBLE
                ChatMessagesView(chatVM: chatVM)
                
                //RECORD
                RecordButton (contentState: $chatVM.contentState) {
                    //check permissions & record
                    chatVM.recordingButtonTapped()
                }
                
                //PROMPTS LIST
                PromptView(didPromptSelected: { prompt in
                    
                   
                })
            }
            
            if chatVM.contentState == .recording {
                GlowEffect(isAnimating: .constant(true))
                    .transition(.opacity)
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            
            if !chatVM.isPermissionsValid(){
                chatVM.requestAllPermissions()
            }
        }
        .alert(item: $alertManager.alert) { alertContent in
            Alert(title: Text(alertContent.title),
                  primaryButton: .default(Text(alertContent.primaryButtonText)){
                chatVM.openSettings()
            }, secondaryButton: .cancel())
        }
        .sheet(item: $activeSettingsSheet) { selection in
            sheetView(for: selection)
        }
        
    }
    
    func sendPromptRequest(prompt: Prompt) {
        Task {
            do {
                try await chatVM.send(text: prompt.text)
                
            } catch (let error) {
                alertManager.showAlert(for: .infoMessage(title: "Network Error", message: "We're failed sending prompt to server. Error: \(error.localizedDescription)", primaryButtonText: "OK", onAction: {}))
            }
        }
    }
}


private func sheetView (for settingsMenu: SettingsMenuData) -> some View {
    switch settingsMenu {
    case .about:
        return AboutSheet()
            .frame(maxWidth: .infinity, maxHeight: 300)
    }
}

//TODO: Remove This

private struct ToolbarView: View {
    
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

private struct ChatMessagesView: View {
    
    @StateObject var chatVM: ChatViewModel
    
    var body: some View {
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
                        }.id(message.id)
                    }
                }.padding()
            }
            .onAppear {
                if let last = chatVM.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            .onChange(of: chatVM.messages.count) { _ in
                guard let last = chatVM.messages.last else { return }
                DispatchQueue.main.async {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

        }
    }
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
        .environmentObject(NetworkManager())
}
