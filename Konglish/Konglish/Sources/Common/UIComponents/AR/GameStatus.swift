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
        .background(Material.ultraThin.quaternary)
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
        Text(GameStatusConstatns.scoreText + " " + "\(currentScore)")
            .font(.bold36)
            .foregroundStyle(Color.black)
    }
    
    /// 카드 현재 수집 정보
    private var currentCardInfo: some View {
        HStack(spacing: GameStatusConstatns.cardHspacing, content: {
            Image(.arCard)
            Text("\(currentCard) / \(maxCount)")
                .font(.bold36)
                .foregroundStyle(Color.black)
        })
    }
}

#Preview {
    @Previewable @State var currentScore: Int = 2
    @Previewable @State var curentCard: Int = 2
    @Previewable @State var currentLife: Int = 2
    
    GameStatus(currentScore: $currentScore, currentCard: $curentCard, currentLife: $currentLife)
}
