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
     @State var arError: Error? // ARCore 발생 에러
     @State var currentDetectedPlanes: Int = 0 // 현재 인식한 평면 수
     @State var triggerScanStart = false // 평면 스캔 시작
     @State var triggerPlaceCards = false // 카드 배치 시작
     @State var gamePhase: GamePhase = .initialized // 현재 게임 단계
     
     let gameCards: [GameCard] = [
         .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, imageName: "apple", wordKor: "사과", wordEng: "apple"),
         // More game cards
     ]
     
     
     public init() {}
     
     public var body: some View {
         ZStack {
             ARContainer(
                 gameSettings: GameSettings(
                     gameCards: gameCards,
                     minimumSizeOfPlane: 0.5
                 ),
                 gamePhase: $gamePhase,
                 arError: $arError,
                 currentDetectedPlanes: $currentDetectedPlanes,
                 triggerScanStart: $triggerScanStart,
                 triggerPlaceCards: $triggerPlaceCards
             )
             .ignoresSafeArea()
             
             VStack {
                 Text("gamePhase: \(gamePhase)")
                 
                 Text("currentDetectedPlanes: \(currentDetectedPlanes)")
                 
                 Button("스캔 시작") {
                     triggerScanStart = true
                 }
                 
                 Button("카드 배치") {
                     triggerPlaceCards = true
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
    
    /// 스캔 시작 트리거
    @Binding var triggerScanStart: Bool
    
    /// 카드 배치 트리거
    @Binding var triggerPlaceCards: Bool
    
    public init(
        gameSettings: GameSettings,
        gamePhase: Binding<GamePhase>,
        arError: Binding<Error?>,
        currentDetectedPlanes: Binding<Int>,
        triggerScanStart: Binding<Bool>,
        triggerPlaceCards: Binding<Bool>
    ) {
        self.gameSettings = gameSettings
        self._gamePhage = gamePhase
        self._arError = arError
        self._currentDetectedPlanes = currentDetectedPlanes
        self._triggerScanStart = triggerScanStart
        self._triggerPlaceCards = triggerPlaceCards
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
                // 따라서 메인 큐에서 비동기로 작성 실행
                raisedError = error
            }
            
            DispatchQueue.main.async {
                triggerPlaceCards.toggle()
                arError = raisedError //
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
    }
}
