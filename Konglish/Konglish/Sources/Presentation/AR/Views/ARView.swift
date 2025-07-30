//
//  ARView.swift
//  Konglish
//
//  Created by 임영택 on 7/29/25.
//

import SwiftUI
import ARCore
import SwiftData
import Dependency

struct ARView: View {
    // MARK: - SwiftData
    let levelModelID: UUID
    @Query var levels: [LevelModel]
    @Query var gameSessions: [GameSessionModel]
    @Query var allCards: [CardModel]
    @EnvironmentObject var container: DIContainer
    
    var selectedLevel: LevelModel? {
        levels.first { levelModel in
            levelModel.id == levelModelID
        }
    }
    
    var selectedGameSession: GameSessionModel? {
        gameSessions.first { gameSessionModel in
            gameSessionModel.level.id == levelModelID
        }
    }
    
    var allPlanesDetected: Bool {
        arViewModel.currentDetectedPlanes == gameCards.count
    }
    
    // ARCore 데이터 모델
    var gameCards: [GameCard] {
        if let selectedLevel {
            let everyCardInLevel = selectedLevel.category.cards.compactMap { GameModelMapper.toGameModel($0) }
            let randomCards = everyCardInLevel.shuffled().prefix(5)
            return Array(randomCards)
        }
        
        return []
    }
    
    // MARK: - View Model
    @State var arViewModel: ARViewModel = .init()
    @State var detailCardViewModel: DetailCardViewModel = .init()
    
    // MARK: - 게임 세팅을 위한 프로퍼티
    /// 최소 평면 사이즈
    let minimumSizeOfPlane: Float = 0.5
    /// 앞면 이미지 타이틀 폰트
    let titleFont: UIFont = KonglishFontFamily.NPSFont.extraBold.font(size: 64)
    /// 앞면 이미지 서브타이틀 폰트
    let subtitleFont: UIFont = KonglishFontFamily.NPSFont.extraBold.font(size: 32)
    
    var body: some View {
        ARContainer(
            gameSettings: .init(
                gameCards: gameCards,
                minimumSizeOfPlane: minimumSizeOfPlane,
                fontSetting: .init(
                    title: titleFont,
                    subtitle: subtitleFont
                )
            ),
            gamePhase: $arViewModel.gamePhase,
            arError: $arViewModel.arError,
            currentDetectedPlanes: $arViewModel.currentDetectedPlanes,
            currentLifeCounts: $arViewModel.currentLifeCounts,
            currentGameScore: $arViewModel.currentGameScore,
            numberOfFinishedCards: $arViewModel.numberOfFinishedCards,
            flippedCardId: $arViewModel.flippedCardId,
            triggerScanStart: $arViewModel.triggerScanStart,
            triggerPlaceCards: $arViewModel.triggerPlaceCards,
            triggerSubmitAccuracy: $arViewModel.triggerSubmitAccuracy,
            triggerFlipCard: $arViewModel.triggerFlipCard
        )
        .overlay {
            Group {
                switch arViewModel.gamePhase {
                case .initialized:
                    StartOverlay(arViewModel: arViewModel)
                case .scanning:
                    CheckScanOverlay(arViewModel: arViewModel, allPlanesDetected: allPlanesDetected)
                case .scanned, .playing:
                    if !arViewModel.showingWordDetailCard {
                        PlayingGameOverlay(arViewModel: arViewModel)
                            .environmentObject(container)
                    } else if let currentSession = selectedGameSession {
                        OnShowingCardOverlay(arViewModel: arViewModel, detailCardViewModel: detailCardViewModel, currentSession: currentSession)
                            .environmentObject(container)
                    }
                case .fisished:
                    if let selectedGameSession {
                        FinishedOverlay(gameSessionModel: selectedGameSession)
                    }
                default:
                    EmptyView()
                }
            }
        }
        .onChange(of: arViewModel.numberOfFinishedCards, { _, newValue in
            if newValue == gameCards.count {
                arViewModel.gamePhase = .fisished
            }
        })
        .onChange(of: arViewModel.flippedCardId) { _, newId in
            if let id = newId {
                detailCardViewModel.word = allCards.first(where: { $0.id == id })
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
}
