//
//  LevelType.swift
//  Konglish
//
//  Created by Apple MacBook on 7/28/25.
//

import Foundation
import SwiftUI

enum LevelType: String, Codable, Hashable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy:
            return .green00
        case .normal:
            return .yellow00
        case .hard:
            return .red04
        }
    }
    
    var fontColor: Color {
        switch self {
        case .easy:
            return .green10
        case .normal:
            return .yellow03
        case .hard:
            return .red04
        }
    }
    
    var buttonStrokeColor: Color {
        switch self {
        case .easy:
            return .green07
        case .normal:
            return .yellow04
        case .hard:
            return .red00
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .easy:
            return .green01
        case .normal:
            return .yellow00
        case .hard:
            return .redBg
        }
    }
    
    
}
