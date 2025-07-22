//
//  ButtonType.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import Foundation
import SwiftUI

enum TextButtonType {
    case start
    case cardSprinkle(onOff: Bool)
    case backMain
    

    var text: String {
        switch self {
        case .start:
            return "시작하기"
        case .cardSprinkle:
            return "카드 뿌리기"
        case .backMain:
            return "메인으로 돌아가기"
        }
    }
    
    var font: Font {
        return .bold40
    }
    
    var color: Color {
        switch self {
        case .start, .backMain:
            return .secondary01
        case .cardSprinkle(let onOff):
            return onOff ? .secondary01 : .offBtn
        }
    }
    
    var bgColor: Color {
        switch self {
        case .start, .backMain:
            return .primary01
        case .cardSprinkle(let onOff):
            return onOff ? .primary01 : .gray01
        }
    }
    
    var btnHeight: CGFloat {
        return 87
    }
}
