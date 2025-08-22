//
//  TestView.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import SwiftUI

struct TestView: View {
    
    @State private var contentState: ContentViewState = .readyToRecord
    
    var body: some View {
        RecordButton(contentState: $contentState)
            .onAppear {
                Task {
                    do {
                        let response = try await ChatGPTManager.shared.requestChatMessage("Whats capital of turkey and give information about city")
                        print("response: \(response)")
                    } catch {
                        print("error: \(error.localizedDescription)")
                    }
                    
                    
                    
                }
            }
    }
}

#Preview {
    TestView()
}
