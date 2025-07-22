//
//  Shadow.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import Foundation
import SwiftUI

struct MainButtonShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .mainShadow01, radius: 0, x: 0, y: 8)
    }
}

extension View {
    func mainButtonShadow() -> some View {
        self.modifier(MainButtonShadow())
    }
}
