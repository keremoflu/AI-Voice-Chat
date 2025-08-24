//
//  ToastManager.swift
//  AIVoiceChat
//
//  Created by Kerem on 24.08.2025.
//

import Foundation
import SwiftUI

class ToastManager: ObservableObject {
    
    @Published var toast: Toast? = nil
    
    func showToast(_ selectedToast: Toast, duration: TimeInterval = 1.0) {
        withAnimation(.easeInOut(duration: 0.25)) {
            toast = selectedToast
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: 0.25)) { [weak self] in
                guard let self else { return }
                toast = nil
            }
        }
    }
}
