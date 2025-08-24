//
//  SplashView.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import SwiftUI

struct SplashView: View {
    
    private let robotSize = UIScreen.main.bounds.width * 0.16
    @State private var text = "Welcome to AI Chat App!\nYou can ask me anything!"
    @State private var isGetStartedButtonActive: Bool = false
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                HStack {
                    Image(.robot)
                        .resizable()
                        .frame(
                            width: robotSize,
                            height: robotSize)
                    
                    SpeechBubbleView(text: $text, isGetStartedActive: $isGetStartedButtonActive)
                        .offset(y: -40)
                }
                Spacer()
                
                NavigationLink {
                    ContentView(networkManager: networkManager)
                } label: {
                    GetStartedLabel(isActive: $isGetStartedButtonActive)
                }
            }
        }
    }
}

private struct GetStartedLabel: View {
    
    @Binding var isActive: Bool
    
    var body: some View {
        Text("Get Started")
            .font(.quickSand(size: 16, name: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: 60)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .foregroundColor(.primaryPurple)
            ).padding()
            .padding(.bottom, 32)
            .opacity(isActive ? 1.0 : 0.0)
            .animation(.easeOut(duration: 0.75), value: isActive)
    }
}

private struct SpeechBubbleView: View {
    
    @Binding var text: String
    @Binding var isGetStartedActive: Bool
    
    var body: some View {
        TypeAnimation(text: $text, isGetStartedActive: $isGetStartedActive)
            .foregroundColor(.white)
            .padding()
            .background(
                SpecificRoundedCorner(radius: 16, corners: [.topLeft, .topRight, .bottomRight])
                    .foregroundColor(.primaryPurple)
            )
            
    }
}

private struct TypeAnimation: View {
    
    @State private var currentCharArray: [String.Element] = []
    @State private var fullCharArray: [String.Element] = []
    @State private var currentIndex: Int = 0
    
    @State private var timer: Timer?
    
    @Binding var text: String
    @Binding var isGetStartedActive: Bool
    
    var body: some View {
        Text(String(currentCharArray))
            .font(.system(size: 16, weight: .medium))
            .onAppear {
                startTimer()
            }
            .onDisappear {
                removeTimer()
            }
    }
    
    private func removeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startTimer() {
        
        fullCharArray = Array(text)
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { _ in
            timerWorked()
        })
        
        
    }
    
    private func timerWorked() {
        guard currentCharArray.count < fullCharArray.count else {
            isGetStartedActive = true
            return
        }
        
        currentCharArray.append(fullCharArray[currentIndex])
        currentIndex += 1
    }
}

#Preview {
    SplashView()
        .environmentObject(NetworkManager())
}
