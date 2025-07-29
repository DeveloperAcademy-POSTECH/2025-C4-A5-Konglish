//
//  Shadow.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import Foundation
import SwiftUI

struct MainButtonShadow: ViewModifier {
    
    let shadowColor: Color
    
    func body(content: Content) -> some View {
        content
            .shadow(color: shadowColor, radius: 0, x: 0, y: 8)
    }
}

struct WhiteButtonShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .gray01, radius: 0, x: 0, y: 4)
    }
}

struct GrayShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .gray01, radius: 0, x: 0, y: 8)
    }
}

extension View {
    func mainButtonShadow(shadowColor: Color) -> some View {
        self.modifier(MainButtonShadow(shadowColor: shadowColor))
    }
    
    func whiteShadow() -> some View {
        self.modifier(WhiteButtonShadow())
    }
    
    func grayShadow() -> some View {
        self.modifier(GrayShadow())
    }
}
