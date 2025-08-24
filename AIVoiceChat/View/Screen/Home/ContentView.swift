//
//  ContentView.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var networkManager: NetworkManager
    @StateObject var chatViewModel: ContentViewModel
    @StateObject private var alertManager = AlertManager()
    @StateObject private var toastManager = ToastManager()
    
    @State var pickedLanguage = UserDefaultsManager.shared.speechCountry
    @State var activeSettingsSheet: SettingsMenuData? = nil
  
    init(networkManager: NetworkManager) {
       let alertManager = AlertManager()
       _alertManager = StateObject(wrappedValue: alertManager)
       _chatViewModel = StateObject(wrappedValue: ContentViewModel(
        networkManager: networkManager,
        alertManager: alertManager))
    }
    
    var body: some View {
        ZStack (alignment: .top) {
           
            Color.background
                .ignoresSafeArea()
            
            VStack {
                
                //LANGUAGE PICKER, SETTINGS
                ToolbarView() { selection in
                    activeSettingsSheet = selection
                }
                
                //CHAT MESSAGE LIST
                ChatMessagesView(messagesCoordinator: chatViewModel.messageCoordinator)
                
                //RECORD
                RecordButton (contentState: $chatViewModel.contentState) {
                    chatViewModel.recordingButtonTapped()
                }
                
                //PROMPTS LIST
                PromptView(didPromptSelected: { prompt in
                    chatViewModel.sendPromptRequest(prompt: prompt)
                })
            }
            
            //GLOW EFFECT in Recording
            if chatViewModel.contentState == .recording {
                GlowEffect()
                    .transition(.opacity)
            }
            
            if let toast = toastManager.toast {
                ToastInfoView(toast: toast)
                    .padding()
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(1)
            }

        }
        .navigationBarBackButtonHidden(true)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if !chatViewModel.isPermissionsValid(){
                chatViewModel.requestAllPermissions()
            }
            
        }
        .alert(item: $alertManager.alert) { alertContent in
            Alert(
                  title: Text(alertContent.title),
                  message: Text(alertContent.message),
                  primaryButton: .default(Text(alertContent.primaryButtonText)){
                      alertContent.primaryAction()
            },    secondaryButton: .cancel())
        }.sheet(item: $activeSettingsSheet) { selection in
            sheetView(for: selection)
        }.onChange(of: networkManager.isConnectionActive) { isActive in
            if !isActive {
                toastManager.showToast(ToastData.networkFailed.toast, duration: 3.0)
            }
        }
    }
}

private func sheetView (for settingsData: SettingsMenuData) -> some View {
    switch settingsData {
    case .about:
        return AboutSheet(settingsMenuData: settingsData)
            .frame(maxWidth: .infinity, maxHeight: 300)
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
    ContentView(networkManager: .init())
        .environmentObject(NetworkManager())
        
}
