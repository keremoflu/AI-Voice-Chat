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
    @StateObject var chatVM = ContentViewModel()
    @StateObject private var alertManager = AlertManager()
    @StateObject private var toastManager = ToastManager()
    
    @State var isAboutSheetVisible = false
    @State var pickedLanguage = UserDefaultsManager.shared.speechCountry
    @State var activeSettingsSheet: SettingsMenuData? = nil
  
    init() {
       let alertManager = AlertManager()
       _alertManager = StateObject(wrappedValue: alertManager)
       _chatVM = StateObject(wrappedValue: ContentViewModel(alertManager: alertManager))
    }
    
    var body: some View {
        ZStack (alignment: .top) {
           
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
                    chatVM.recordingButtonTapped()
                }
                
                //PROMPTS LIST
                PromptView(didPromptSelected: { prompt in
                    chatVM.sendPromptRequest(prompt: prompt)
                })
            }
            
            //GLOW EFFECT in Recording
            if chatVM.contentState == .recording {
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if !chatVM.isPermissionsValid(){
                chatVM.requestAllPermissions()
            }
            
        }
        .alert(item: $alertManager.alert) { alertContent in
            Alert(
                  title: Text(alertContent.title),
                  message: Text(alertContent.message),
                  primaryButton: .default(Text(alertContent.primaryButtonText)){
                      alertContent.primaryAction()
            },    secondaryButton: .cancel())
        }
        .sheet(item: $activeSettingsSheet) { selection in
            sheetView(for: selection)
        }.onChange(of: networkManager.isConnectionActive) { isActive in
            if !isActive {
                toastManager.showToast(ToastData.networkFailed.toast, duration: 3.0)
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
