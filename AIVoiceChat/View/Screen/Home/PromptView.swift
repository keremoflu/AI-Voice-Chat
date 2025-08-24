//
//  PromptView.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import SwiftUI

struct PromptView: View {
    
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

#Preview {
    PromptView { _ in
        
    }
}
