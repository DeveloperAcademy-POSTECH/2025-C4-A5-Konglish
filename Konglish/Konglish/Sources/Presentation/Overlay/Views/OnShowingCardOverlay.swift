//
//  OnShowingCardOverlay.swift
//  Konglish
//
//  Created by 임영택 on 7/29/25.
//

import SwiftUI
import Dependency
import SwiftData

/// 플레잉 중 카드 뒤집혔을 때 오버레이
struct OnShowingCardOverlay: View {
    @Bindable var arViewModel: ARViewModel
    var detailCardViewModel: DetailCardViewModel
    @EnvironmentObject var container: DIContainer
    @Environment(\.modelContext) private var modelContext
    @Query var allCards: [CardModel]
    
    var currentSession: GameSessionModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            if arViewModel.showingWordDetailCard {
                WordDetailCard(viewModel: detailCardViewModel)
            }
        }
        .overlay(alignment: .topLeading, content: {
            GameStatus(currentScore: $arViewModel.currentGameScore,
                       currentCard: $arViewModel.numberOfFinishedCards,
                       currentLife: $arViewModel.currentLifeCounts)
        })
        .overlay(alignment: .topTrailing, content: {
            MainButton(buttonType: .icon(.exit)) {
                container.navigationRouter.pop()
            }
        })
        .overlay(alignment: .bottomLeading, content: {
            MainButton(buttonType: .icon(.sound)) {
                detailCardViewModel.speakWord()
            }
        })
        .overlay(alignment: .bottomTrailing, content: {
            MainButton(buttonType: .icon(.mic)) {
                handlePronunciationAndSave()
            }
        })
        .overlay(alignment: .leading, content: {
            MainButton(buttonType: .icon(.close)) {
                arViewModel.showingWordDetailCard.toggle()
            }
        })
        .safeAreaPadding(.horizontal, UIConstants.horizontalPading)
        .safeAreaPadding(.bottom, UIConstants.horizonBtnPadding)
        .safeAreaPadding(.top, UIConstants.topPadding)
    }
    
    private func handlePronunciationAndSave() {
        Task {
            await detailCardViewModel.startPronunciationEvaluation()

            if let word = detailCardViewModel.word {
                let usedCard = UsedCardModel(session: currentSession, card: word)
                modelContext.insert(usedCard)
                try? modelContext.save()
                print("UsedCard 저장 완료: \(word.wordEng)")
            }
        }
    }
}
