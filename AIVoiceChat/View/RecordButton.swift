//
//  RecordButton.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import SwiftUI

struct RecordButton: View {
    
    @Binding var contentState: ContentViewState
    var action: () -> Void
    
    var body: some View {
        
        Button {
            action()
        } label: {
            switch contentState {
            case .readyToRecord:
                IdleRecordButton()
            case .recording:
                RecordingButton()
            case .loadingAfterRecord:
                LoadingRecordButton()
            }
        }.accessibilityLabel("Audio Record Button")
    }
}

struct RecordButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .foregroundColor(.white)
            .padding(32)
        
    }
}

private struct LoadingRecordButton: View {
    @State private var isAnimating = false
    
    var body: some View {
        
        Image(systemName: "progress.indicator")
            .modifier(RecordButtonModifier())
            .background(
                Circle()
                    .foregroundColor(.grayPrimary)
                    .padding(8)
                    .background(
                        Circle().foregroundColor(.grayPrimary).opacity(0.16)
                    )
            ).rotationEffect(.degrees(isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

private struct IdleRecordButton: View {
    var body: some View {
        
        Image(systemName: "microphone.fill")
            .modifier(RecordButtonModifier())
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

private struct RecordingButton: View {
    
    @State private var pulse = false
    
    var body: some View {
        Image(systemName: "stop.fill")
            .modifier(RecordButtonModifier())
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
    RecordButton(contentState: .constant(.readyToRecord)) {
        
    }
}

