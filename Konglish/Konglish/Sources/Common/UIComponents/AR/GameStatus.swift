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
    let maxCount: Int = 5
    
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
        static let cardBottomSpacing: CGFloat = 0
        static let cardBottomImagePadding: CGFloat = 16
        static let scoreLabelWidth: CGFloat = 94
        static let cardsLabelWidth: CGFloat = 140
        
        static let dropShadowSize: CGFloat = 6
        
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
        .glassShadow(GameStatusConstatns.dropShadowSize)
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
        HStack(spacing: GameStatusConstatns.cardBottomSpacing) {
            Image(.bin)
                .resizable()
                .frame(width: GameStatusConstatns.binWidth, height: GameStatusConstatns.binHeight)
            
            Spacer()
                .frame(width: GameStatusConstatns.cardBottomImagePadding)
            
            Text("\(currentScore)")
                .font(.poetsen48)
                .foregroundStyle(Color.black)
                .customOutline(width: 1, color: .white01)
                .frame(width: GameStatusConstatns.scoreLabelWidth, alignment: .leading)
        }
        .safeAreaPadding(.leading, 10)
    }
    
    /// 카드 현재 수집 정보
    private var currentCardInfo: some View {
        HStack(spacing: GameStatusConstatns.cardHspacing, content: {
            Image(.totalCard)
            Text("\(currentCard) / \(maxCount)")
                .font(.poetsen48)
                .foregroundStyle(Color.black01)
                .customOutline(width: 1, color: .white01)
                .frame(width: GameStatusConstatns.cardsLabelWidth)
        })
    }
}

#Preview {
    @Previewable @State var currentScore: Int = 2
    @Previewable @State var curentCard: Int = 2
    @Previewable @State var currentLife: Int = 2
    
    GameStatus(currentScore: $currentScore, currentCard: $curentCard, currentLife: $currentLife)
}
