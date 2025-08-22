//
//  RecordButton.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import SwiftUI

struct RecordButton: View {
    
    //Convert to Binding
    @Binding var contentState: ContentViewState
    
    var body: some View {
        
        Button {
            contentState = .recording
            print("tapo!")
        } label: {
            if contentState == .recording {
                RecordingButton()
            } else {
                IdleRecordButton()
            }
        }
        
        
    }
}

struct IdleRecordButton: View {
    var body: some View {
        
        Image(systemName: "microphone.fill")
            .font(.title)
            .foregroundColor(.white)
            .padding(32)
            .background(
                Circle()
                    .foregroundColor(.primaryPurple)
                    .padding(8)
                    .background(
                        Circle().foregroundColor(.primaryPurple).opacity(0.16)
                    )
            )
        
    }
}

struct RecordingButton: View {
    
    @State private var pulse = false
    
    var body: some View {
        Image(systemName: "stop.fill")
            .font(.title)
            .foregroundColor(.white)
            .padding(32)
            .background(
                Circle()
                    .foregroundColor(.primaryRed)
                    .shadow(color: .primaryRed.opacity(pulse ? 0.8 : 0.6), radius: pulse ? 16 : 8)
                    .padding(8)
                    .background(
                        Circle().stroke(Color.primaryRed.opacity(pulse ? 0.5 : 0.2), lineWidth: 2.0)
                    )
            )
            .onAppear{ pulse = true }
            .onDisappear { pulse = false }
            .animation(
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                value: pulse)
    }
}
#Preview {
    RecordButton(contentState: .constant(.readyToRecord))
}

