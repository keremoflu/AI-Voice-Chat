//
//  PromptHorizontalListView.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import SwiftUI

struct PromptHorizontalListView: View {

    var isPromptSelected: (Prompt) -> Void
    
    var body: some View {
        ScrollView (.horizontal) {
            HStack {
                ForEach(PromptData.prompts, id: \.self) { item in
                    PromptCellView(prompt: item)
                        
                        .onTapGesture {
                            isPromptSelected(item)
                        }
                }
            }.padding(.horizontal)
        }
    }
}

private struct PromptCellView: View {
    
    var prompt: Prompt
    
    var body: some View {
        HStack (spacing: 10) {
            Image(prompt.image)
                .resizable()
                .frame(width: 24, height: 24)
            Text(prompt.text)
                .font(.quickSand(size: 16, name: .medium))
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .minimumScaleFactor(0.25)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
        )
        .frame(width: UIScreen.main.bounds.width * 0.6)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    PromptHorizontalListView(isPromptSelected: {_ in })
}
