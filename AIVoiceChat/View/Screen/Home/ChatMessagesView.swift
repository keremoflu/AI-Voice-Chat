//
//  ChatMessagesView.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import SwiftUI

struct ChatMessagesView: View {
    
    @StateObject var messagesCoordinator: MessageCoordinator
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(messagesCoordinator.messages, id: \.id) { message in
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
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: messagesCoordinator.messages.last?.text) { _ in
                scrollToBottom(proxy: proxy)
            }

        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let lastMessage = messagesCoordinator.messages.last else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatMessagesView(messagesCoordinator: MessageCoordinator())
}
