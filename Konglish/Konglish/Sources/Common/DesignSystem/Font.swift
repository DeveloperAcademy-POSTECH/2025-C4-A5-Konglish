//
//  Font.swift
//  Konglish
//
//  Created by Apple MacBook on 7/21/25.
//

import Foundation
import SwiftUI

public extension Font {
    enum Konglish {
        case bold
        case extraBold
        case regular
        
        var fontConvertible: KonglishFontConvertible {
            switch self {
            case .bold:
                return KonglishFontFamily.NPSFont.bold
            case .extraBold:
                return KonglishFontFamily.NPSFont.extraBold
            case .regular:
                return KonglishFontFamily.NPSFont.regular
            }
        }
        
        func font(size: CGFloat) -> Font {
            fontConvertible.swiftUIFont(size: size)
        }
    }
    
    enum Poetsen {
        case regular
        
        var fontConvertible: KonglishFontConvertible {
            switch self {
            case .regular:
                return KonglishFontFamily.PoetsenOne.regular
            }
        }
        
        func font(size: CGFloat) -> Font {
            fontConvertible.swiftUIFont(size: size)
        }
    }
    
    static func konglish(_ type: Konglish, size: CGFloat) -> Font {
        return type.font(size: size)
    }
    
    static func poetsen(_ type: Poetsen, size: CGFloat) -> Font {
        return type.font(size: size)
    }
    
    // MARK: - ExtraBold
    static var semibold64: Font {
        return .konglish(.extraBold, size: 64)
    }
    
    static var semibold104: Font {
        return .konglish(.extraBold, size: 104)
    }
    
    static var semibold36: Font {
        return .konglish(.extraBold, size: 36)
    }
    
    static var semibold32: Font {
        return .konglish(.extraBold, size: 32)
    }
    
    static var semibold24: Font {
        return .konglish(.extraBold, size: 24)
    }
    
    static var semibold20: Font {
        return .konglish(.extraBold, size: 20)
    }
    
    static var semibold16: Font {
        return .konglish(.extraBold, size: 16)
    }
    
    static var poetsen48: Font {
        return .poetsen(.regular, size: 48)
    }
    
    // MARK: - Bold
    static var bold80: Font {
        return .konglish(.bold, size: 80)
    }
    
    static var bold40: Font {
        return .konglish(.bold, size: 40)
    }
    
    static var bold36: Font {
        return .konglish(.bold, size: 36)
    }
    
    static var bold32: Font {
        return .konglish(.bold, size: 32)
    }
    
    static var bold24: Font {
        return .konglish(.bold, size: 24)
    }
    
    static var bold20: Font {
        return .konglish(.bold, size: 20)
    }
    
    static var bold16: Font {
        return .konglish(.bold, size: 16)
    }
}
