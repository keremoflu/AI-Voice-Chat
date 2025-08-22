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
    }
}

#Preview {
    TestView()
}
