//
//  LevelCard.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import SwiftUI

struct ButtonCard<Contents: View>: View {
    
    // MARK: - Property
    let content: () -> Contents
    let action: () -> Void
    let cardWidth: CGFloat = 280
    let cardTopHeight: CGFloat = 440
    let cornerRadius: CGFloat = 20
    
    // MARK: - Init
    init(
        @ViewBuilder content: @escaping () -> Contents,
        action: @escaping () -> Void
    ) {
        self.content = content
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        Button(action: {
            action()
        }, label: {
            ZStack {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white)
                    .frame(width: cardWidth, height: cardTopHeight)
                    .grayShadow()
                
                content()
            }
            .padding(.bottom, 8)
        })
        .buttonStyle(.plain)
    }
}
