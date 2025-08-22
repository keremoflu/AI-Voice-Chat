//
//  TestView.swift
//  AIVoiceChat
//
//  Created by Kerem on 22.08.2025.
//

import SwiftUI

struct TestView: View {
    
    @State private var contentState: ContentViewState = .readyToRecord
    @EnvironmentObject var networkManager: NetworkManager
    
    var body: some View {
        RecordButton(contentState: $contentState)
        Text("CURRENT: \(networkManager.isConnectionActive)")
        
    }
}

#Preview {
    TestView()
    
}
