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
    case openPotal(onOff: Bool)
    case backMain
    case restart
    case returnCategory
    

    var text: String {
        switch self {
        case .start:
            return "시작하기"
        case .cardSprinkle:
            return "저 넘어 세상엔..?"
        case .openPotal:
            return "단어 세상 포탈 열기!"
        case .backMain:
            return "카테고리로 돌아가기"
        case .restart:
            return "다시 도전하기!"
        case .returnCategory:
            return "카테고리로 돌아가기"
        }
    }
    
    var font: Font {
        return .bold40
    }
    
    var color: Color {
        switch self {
        case .start, .backMain, .restart:
            return .green09
        case .cardSprinkle(let onOff), .openPotal(let onOff):
            return onOff ? .green09 : .offBtn
        case .returnCategory:
            return .white01
        }
    }
    
    var bgColor: Color {
        switch self {
        case .start, .backMain, .restart:
            return .green02
        case .cardSprinkle(let onOff), .openPotal(let onOff):
            return onOff ? .green02 : .gray01
        case .returnCategory:
            return .green08
        }
    }
    
    var btnHeight: CGFloat {
        return 87
    }
    
    var shadowColor: Color {
        switch self {
        case .start:
            return .green09
        case .cardSprinkle(let onOff), .openPotal(let onOff):
            return onOff ? .green09 : .gray03
        case .backMain, .restart:
            return .greenShadow
        case .returnCategory:
            return .returnCategoryShadow
        }
    }
}
