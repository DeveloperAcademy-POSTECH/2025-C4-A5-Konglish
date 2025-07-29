//
//  GameStatus.swift
//  Konglish
//
//  Created by Apple MacBook on 7/23/25.
//

import SwiftUI

struct GameStatus: View {
    
    // MARK: - Property
    @Binding var currentScore: Int
    @Binding var currentCard: Int
    @Binding var currentLife: Int
    let maxCount: Int = 15
    
    // MARK: - Constants
    fileprivate enum GameStatusConstatns {
        static let bottomInfoWidth: CGFloat = 440
        static let verticalPadding: CGFloat = 8
        static let horizonPadding: CGFloat = 16
        static let statusVspacing: CGFloat = 10
        static let cardHspacing: CGFloat = 8
        static let bottomInfoHspacing: CGFloat = 20
        static let cornerRadius: CGFloat = 30
        static let binWidth: CGFloat = 40
        static let binHeight: CGFloat = 34
        
        static let scoreText: String = "Score"
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: GameStatusConstatns.statusVspacing, content: {
            LifeHeart(currentLife: currentLife)
            bottomContents
        })
        .padding(.vertical, GameStatusConstatns.verticalPadding)
        .padding(.horizontal, GameStatusConstatns.horizonPadding)
        .background(Material.thin.quaternary)
        .clipShape(RoundedRectangle(cornerRadius: GameStatusConstatns.cornerRadius))
    }
    // MARK: - Bottom
    /// 하단 점수 및 카드 수집 정보
    private var bottomContents: some View {
        HStack(spacing: GameStatusConstatns.bottomInfoHspacing, content: {
            scoreText
            currentCardInfo
        })
        .frame(width: GameStatusConstatns.bottomInfoWidth, alignment: .leading)
    }
    
    /// 현재 스코어 표시 텍스트
    private var scoreText: some View {
        Label(title: {
            Text("\(currentScore)")
                .font(.bold40)
                .foregroundStyle(Color.black)
                .customOutline(width: 1, color: .white01)
        }, icon: {
            Image(.bin)
                .resizable()
                .frame(width: GameStatusConstatns.binWidth, height: GameStatusConstatns.binHeight)
        })
    }
    
    /// 카드 현재 수집 정보
    private var currentCardInfo: some View {
        HStack(spacing: GameStatusConstatns.cardHspacing, content: {
            Image(.totalCard)
            Text("\(currentCard) / \(maxCount)")
                .font(.bold40)
                .foregroundStyle(Color.black01)
                .customOutline(width: 1, color: .white01)
        })
    }
}

#Preview {
    @Previewable @State var currentScore: Int = 2
    @Previewable @State var curentCard: Int = 2
    @Previewable @State var currentLife: Int = 2
    
    GameStatus(currentScore: $currentScore, currentCard: $curentCard, currentLife: $currentLife)
}
