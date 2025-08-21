//
//  PromptHorizontalListView.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI

struct PromptHorizontalListView: View {
    var body: some View {
        PromptCellView()
    }
}

private struct PromptCellView: View {
    var body: some View {
        HStack {
            Image(systemName: "star.fill")
                .font(.system(size: 16, weight: .regular))
            Text("What do I need to learn playing harmonica?")
                .lineLimit(2)
        }
    }
}

#Preview {
    PromptHorizontalListView()
}
