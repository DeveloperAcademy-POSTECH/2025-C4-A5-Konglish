//
//  NaviTitleType.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import Foundation
import SwiftUI

enum NaviTitleType: String {
    case selectCategoty = "카테고리 선택"
    case selectLevel = "레벨 선택"
    
    var font: Font {
        return .semibold64
    }
    
    var color: Color {
        return .green02
    }
}
