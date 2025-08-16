//
//  AccuracyType.swift
//  Konglish
//
//  Created by Apple MacBook on 7/24/25.
//

import Foundation
import SwiftUI

enum AccuracyType {
    case btnMic
    case success
    case failure
    
    var text: String {
        switch self {
        case .btnMic:
            return "마이크 버튼을 눌러 따라해보세요"
        case .success:
            return "아주 잘했어요!"
        case .failure:
            return "다시 한번 해볼까요?"
        }
    }
    
    var image: ImageResource? {
        switch self {
        case .btnMic:
            return nil
        case .success:
            return .greenCheck
        case .failure:
            return .redFailure
        }
    }
    
    var font: Font {
        return .bold20
    }
    
    var color: Color {
        switch self {
        case .btnMic:
            return .green05
        case .success:
            return .green09
        case .failure:
            return .red01
        }
    }
}
