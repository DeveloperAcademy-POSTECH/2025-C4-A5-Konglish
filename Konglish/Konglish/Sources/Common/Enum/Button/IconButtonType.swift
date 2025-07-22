//
//  IconButtonType.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import Foundation
import SwiftUI

enum IconButtonType {
    case back
    case exit
    case close
    case sound
    case mic
    case aim
    
    var image: ImageResource {
        switch self {
        case .back:
            return .back
        case .exit:
            return .exit
        case .close:
            return .close
        case .sound:
            return .sound
        case .mic:
            return .mic
        case .aim:
            return .aim
        }
    }
    
    var btnSize: (CGFloat, CGFloat) {
        return (90, 96)
    }
    
    var bgColor: Color {
        return .primary01
    }
    
}
