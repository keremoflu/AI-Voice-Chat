//
//  ChatMessagesView.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import SwiftUI

struct ChatMessagesView: View {
    
    @StateObject var chatVM: ContentViewModel
    
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


#Preview {
    ChatMessagesView(chatVM: ContentViewModel())
}
