//
//  ARContainer.swift
//  ARCoreManifests
//
//  Created by 임영택 on 7/19/25.
//

import SwiftUI

/**
 ARContainerViewController를 SwiftUI로 브릿지하는 UIViewControllerRepresentable 클래스
 
 사용 예시
 
 ```swift
 import SwiftUI
 import ARCore

 public struct ContentView: View {
     @State var arError: Error?
     @State var currentDetectedPlanes: Int = 0
     @State var currentLifeCounts: Int = 5
     @State var currentGameScore: Int = 0
     @State var numberOfFinishedCards: Int = 0
     @State var triggerScanStart = false
     @State var triggerPlaceCards = false
     @State var triggerSubmitAccuracy: (UUID, Float)?
     @State var gamePhase: GamePhase = .initialized
     @State var triggerFlipCard = false
     @State var flippedCardId: UUID?
     
     let gameCards: [GameCard] = [
         .init(
             id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
             imageName: "apple",
             wordKor: "사과",
             wordEng: "apple",
             image: UIImage(systemName: "apple.logo")!
         ),
         .init(
             id: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
             imageName: "banana",
             wordKor: "바나나",
             wordEng: "banana",
             image: UIImage(systemName: "questionmark.app.fill")!
         ),
     ]
     
     
     public init() {}
     
     public var body: some View {
         ZStack {
             ARContainer(
                 gameSettings: GameSettings(
                     gameCards: gameCards,
                     minimumSizeOfPlane: 0.5,
                     fontSetting: ARCoreFontSetting(
                         title: KonglishFontFamily.NPSFont.extraBold.font(size: 64),
                         subtitle: KonglishFontFamily.NPSFont.bold.font(size: 32)
                     )
                 ),
                 gamePhase: $gamePhase,
                 arError: $arError,
                 currentDetectedPlanes: $currentDetectedPlanes,
                 currentLifeCounts: $currentLifeCounts,
                 currentGameScore: $currentGameScore,
                 numberOfFinishedCards: $numberOfFinishedCards,
                 flippedCardId: $flippedCardId,
                 triggerScanStart: $triggerScanStart,
                 triggerPlaceCards: $triggerPlaceCards,
                 triggerSubmitAccuracy: $triggerSubmitAccuracy,
                 triggerFlipCard: $triggerFlipCard
             )
             .ignoresSafeArea()
             
             VStack {
                 Text("gamePhase: \(gamePhase)")
                 
                 Text("currentDetectedPlanes: \(currentDetectedPlanes)")
                 
                 Text("currentLifeCounts: \(currentLifeCounts)")
                 
                 Text("currentGameScore: \(currentGameScore)")
                 
                 Text("numberOfPassedCards: \(numberOfFinishedCards)")
                 
                 Button("스캔 시작") {
                     triggerScanStart = true
                 }
                 
                 Button("카드 배치") {
                     triggerPlaceCards = true
                 }
                 
                 Button("단어 정답 제출 1") {
                     if let id = gameCards.first?.id {
                         triggerSubmitAccuracy = (
                             id,
                             0.6
                         )
                     }
                 }
                 
                 Button("단어 정답 제출 2") {
                     if gameCards.count >= 2 {
                         triggerSubmitAccuracy = (
                             gameCards[1].id,
                             0.3
                         )
                     }
                 }
                 
                 Button("카드 뒤집기") {
                     triggerFlipCard = true
                 }
                 
                 if let flippedCardId = flippedCardId {
                     Text("뒤집힌 카드: \(flippedCardId)")
                 }
                 
                 if let arError = arError {
                     Text("에러: \(arError.localizedDescription)")
                 }
                 
                 Spacer()
             }
         }
     }
 }

 ```
 */
public struct ARContainer: UIViewControllerRepresentable {
    // MARK: - Properties
    let gameSettings: GameSettings
    
    /// 현재 발생한 에러. 에러가 없으면 nil
    @Binding var gamePhage: GamePhase
    
    /// 현재 발생한 에러. 에러가 없으면 nil
    @Binding var arError: Error?
    
    /// 현재 인식된 평면 수
    @Binding var currentDetectedPlanes: Int
    
    /// 현재 라이프 카운트 수
    @Binding var currentLifeCounts: Int
    
    /// 현재 게임 스코어
    @Binding var currentGameScore: Int
    
    /// 해결한 카드 수
    @Binding var numberOfFinishedCards: Int
    
    /// 스캔 시작 트리거
    @Binding var triggerScanStart: Bool
    
    /// 카드 배치 트리거
    @Binding var triggerPlaceCards: Bool
    
    /// 카드 뒤집기 트리거
    @Binding var triggerFlipCard: Bool
    
    /// 뒤집힌 카드 UUID
    @Binding var flippedCardId: UUID?
    
    /// 단어의 아이디와 정확도
    /// 세팅하면 ARContainer에서 점수를 계산해 반영한다
    @Binding var triggerSubmitAccuracy: (UUID, Float)?
    
    public init(
        gameSettings: GameSettings,
        gamePhase: Binding<GamePhase>,
        arError: Binding<Error?>,
        currentDetectedPlanes: Binding<Int>,
        currentLifeCounts: Binding<Int>,
        currentGameScore: Binding<Int>,
        numberOfFinishedCards: Binding<Int>,
        flippedCardId: Binding<UUID?>,
        triggerScanStart: Binding<Bool>,
        triggerPlaceCards: Binding<Bool>,
        triggerSubmitAccuracy: Binding<(UUID, Float)?>,
        triggerFlipCard: Binding<Bool>
    ) {
        self.gameSettings = gameSettings
        self._gamePhage = gamePhase
        self._arError = arError
        self._currentDetectedPlanes = currentDetectedPlanes
        self._currentLifeCounts = currentLifeCounts
        self._currentGameScore = currentGameScore
        self._numberOfFinishedCards = numberOfFinishedCards
        self._flippedCardId = flippedCardId
        self._triggerScanStart = triggerScanStart
        self._triggerPlaceCards = triggerPlaceCards
        self._triggerSubmitAccuracy = triggerSubmitAccuracy
        self._triggerFlipCard = triggerFlipCard
    }
    
    public func makeUIViewController(context: Context) -> ARContainerViewController {
        let viewController = ARContainerViewController(gameSettings: gameSettings)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ARContainerViewController, context: Context) {
        if triggerScanStart {
            uiViewController.startDetectingPlane()
            
            DispatchQueue.main.async {
                triggerScanStart.toggle()
            }
        }
        
        if triggerPlaceCards {
            var raisedError: Error?
            do {
                try uiViewController.placeCards()
            } catch {
                // 바로 Binding을 통해 Publish하면
                // `Modifying state during view update, this will cause undefined behavior` 경고 발생
                // 따라서 메인 큐에서 비동기로 실행
                raisedError = error
            }
            
            DispatchQueue.main.async {
                triggerPlaceCards.toggle()
                arError = raisedError
            }
        }
        
        if let triggerSubmitAccuracy = triggerSubmitAccuracy {
            let (wordId, accuracy) = triggerSubmitAccuracy
            
            var raisedError: Error?
            do {
                try uiViewController.submitAccuracy(wordId: wordId, accuracy: accuracy)
            } catch {
                // 메인 큐에서 비동기로 에러 바인딩 업데이트
                raisedError = error
            }
            
            DispatchQueue.main.async {
                self.triggerSubmitAccuracy = nil
                arError = raisedError
            }
        }
        
        if triggerFlipCard {
            let cardId = uiViewController.flipCardAtCenter()
            
            DispatchQueue.main.async {
                triggerFlipCard.toggle()
                flippedCardId = cardId
            }
        }
        
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: ARContainerViewControllerDelegate {
        var parent: ARContainer
        
        init(_ parent : ARContainer) {
            self.parent = parent
        }
        
        public func arContainerDidFindPlaneAnchor(_ arContainer: ARContainerViewController) {
            parent.currentDetectedPlanes += 1
        }
        
        public func arContainerDidFindAllPlaneAnchor(_ arContainer: ARContainerViewController) {
            // TODO: 추후에 게임 준비 완료 등 게임 전역 상태를 관리하게 되면, 여기서 "카드 배치 준비 완료"로 전역 상태를 변경
        }
        
        public func didChangeGamePhase(_ arContainer: ARContainerViewController) {
            DispatchQueue.main.async {
                self.parent.gamePhage = arContainer.gamePhase
            }
        }
        
        public func didChangeLifeCount(_ arContainer: ARContainerViewController) {
            DispatchQueue.main.async {
                self.parent.currentLifeCounts = arContainer.reaminLifeCounts
            }
        }
        
        public func didChangeScore(_ arContainer: ARContainerViewController) {
            DispatchQueue.main.async {
                self.parent.currentGameScore = arContainer.currentScore
                self.parent.numberOfFinishedCards = arContainer.numberOfFinishedCards
            }
        }
    }
}
