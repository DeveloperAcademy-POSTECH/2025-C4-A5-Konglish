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
    
    fileprivate enum OnShowingCardConstants {
        static let bottomPadding: CGFloat = 177
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
        }
        .overlay(alignment: .center, content: {
            if arViewModel.showingWordDetailCard {
                WordDetailCard(detailCardViewModel: detailCardViewModel, arViewModel: arViewModel)
            }
        })
        .overlay(alignment: .topLeading, content: {
            GameStatus(currentScore: $arViewModel.currentGameScore,
                       currentCard: $arViewModel.numberOfFinishedCards,
                       currentLife: $arViewModel.currentLifeCounts)
        })
        .overlay(alignment: .bottomLeading, content: {
            MainButton(buttonType: .icon(.sound)) {
                detailCardViewModel.speakWord()
                print(detailCardViewModel.word?.wordEng ?? "데이터 없음")
            }
            .padding(.bottom, OnShowingCardConstants.bottomPadding - UIConstants.bottomPadding)
        })
        .overlay(alignment: .bottomTrailing, content: {
            MainButton(buttonType: .icon(.mic)) {
                if detailCardViewModel.recordingState == .recording {
                    detailCardViewModel.stopRecording()
                    
                    if let word = detailCardViewModel.word { // FIXME: 이걸 여기서 저장하는게 맞나...? 어디서 저장되는지 한참 찾았네...
                        let usedCard = UsedCardModel(session: currentSession, card: word)
                        modelContext.insert(usedCard)
                        try? modelContext.save()
                        print("UsedCard 저장 완료: \(word.wordEng)")
                    }
                } else {
                    detailCardViewModel.startRecording()
                }
            }
            .padding(.bottom, OnShowingCardConstants.bottomPadding - UIConstants.bottomPadding)
        })
        .overlay(alignment: .trailing, content: {
            MainButton(buttonType: .icon(.close)) {
                withAnimation(.easeInOut) {
                    arViewModel.showingWordDetailCard.toggle()
                }
            }
        })
        .safeAreaPadding(.horizontal, UIConstants.topPadding)
        .safeAreaPadding(.top, UIConstants.topPadding)
        .navigationBarBackButtonHidden(true)
        .pauseButton()
        .task {
            detailCardViewModel.speakWord()
        }
    }
}
