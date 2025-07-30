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
    @State private var detailCardViewModel = DetailCardViewModel()
    @EnvironmentObject var container: DIContainer
    @Environment(\.modelContext) private var modelContext
    @Query var allCards: [CardModel]

    var currentSession: GameSessionModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)

            if arViewModel.showingWordDetailCard {
                WordDetailCard(viewModel: detailCardViewModel)
            }

            VStack {
                HStack {
                    GameStatus(currentScore: $arViewModel.currentGameScore,
                               currentCard: $arViewModel.numberOfFinishedCards,
                               currentLife: $arViewModel.currentLifeCounts)

                    Spacer()

                    MainButton(buttonType: .icon(.exit)) {
                        container.navigationRouter.pop()
                    }
                }

                Spacer()

                HStack {
                    MainButton(buttonType: .icon(.close)) {
                        arViewModel.showingWordDetailCard.toggle()
                    }

                    Spacer()

                    MainButton(buttonType: .icon(.sound)) {
                        detailCardViewModel.speakWord()
                    }

                    MainButton(buttonType: .icon(.mic)) {
                        handlePronunciationAndSave()
                    }
                }
            }
            .padding()
        }
        .onChange(of: arViewModel.flippedCardId) { _, newId in
            if let id = newId, arViewModel.showingWordDetailCard {
                detailCardViewModel.word = allCards.first(where: { $0.id == id })
            }
        }
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
