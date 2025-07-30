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
        }
        .overlay(alignment: .center, content: {
            if arViewModel.showingWordDetailCard {
                WordDetailCard(viewModel: detailCardViewModel)
            }
        })
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
                // FIXME: 발음 평가 정상화 후 아래 수정
                if detailCardViewModel.recordingState == .recording {
                    detailCardViewModel.stopRecording()
//                    detailCardViewModel.evaluate()
                    detailCardViewModel.evaluateStub()
                    
                    if let word = detailCardViewModel.word {
                        let usedCard = UsedCardModel(session: currentSession, card: word)
                        modelContext.insert(usedCard)
                        try? modelContext.save()
                        print("UsedCard 저장 완료: \(word.wordEng)")
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        arViewModel.showingWordDetailCard = false
                        arViewModel.flippedCardId = nil
                        detailCardViewModel.lastPassed = false
                        detailCardViewModel.lastEvaluatedScore = nil
                        detailCardViewModel.accuracyType = .btnMic
                    }
                } else {
                    detailCardViewModel.startRecording()
                }
            }
        })
        .overlay(alignment: .trailing, content: {
            MainButton(buttonType: .icon(.close)) {
                arViewModel.showingWordDetailCard.toggle()
            }
        })
        .safeAreaPadding(.horizontal, UIConstants.horizontalPading)
        .safeAreaPadding(.bottom, UIConstants.bottomPadding)
        .safeAreaPadding(.top, UIConstants.topPadding)
        .navigationBarBackButtonHidden(true)
        .onChange(of: detailCardViewModel.heart) { _, newValue in
            arViewModel.currentLifeCounts = newValue
        }
        .onChange(of: detailCardViewModel.currentScore) { _, newValue in
            arViewModel.currentGameScore = newValue
            arViewModel.numberOfFinishedCards = detailCardViewModel.finishedCards.count
        }
    }
}
