//
//  Font+Extension.swift
//  AIVoiceChat
//
//  Created by Kerem on 21.08.2025.
//

import Foundation
import SwiftUI

extension Font {
    
    enum QuickSandName: String {
        case light = "Quicksand-Light"
        case regular = "Quicksand-Regular"
        case medium = "Quicksand-Medium"
        case semibold = "Quicksand-SemiBold"
        case bold = "Quicksand-Bold"
    }
    
    static func quickSand(size: CGFloat, name: QuickSandName) -> Font {
        return Font.custom(name.rawValue, size: size)
    }
    
}
