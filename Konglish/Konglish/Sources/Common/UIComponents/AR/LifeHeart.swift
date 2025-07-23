//
//  GameStatus.swift
//  Konglish
//
//  Created by Apple MacBook on 7/23/25.
//

import SwiftUI

/// 생명 표시 하트
struct LifeHeart: View {
    
    // MARK: - Property
    let currentLife: Int
    let maxCount: Int = 5
    
    // MARK: - Constants
    fileprivate enum GameStatusConstatns {
        static let spacing: CGFloat = 16
    }
    
    
    // MARK: - Init
    init(currentLife: Int) {
        self.currentLife = currentLife
    }
    // MARK: - Body
    var body: some View {
        HStack(spacing: GameStatusConstatns.spacing, content: {
            ForEach(0..<maxCount, id: \.self) { index in
                if index < currentLife {
                    Image(.heart)
                } else {
                    Image(.emptyHeart)
                }
            }
        })
    }
}

#Preview {
    LifeHeart(currentLife: 3)
}
