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
     @State var currentDetectedPlanes: Int = 0
     @State var cardScatterTrigger = false
     
     let gameCards: [GameCard] = [
         .init(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, imageName: "apple", wordKor: "사과", wordEng: "apple"),
          /* 생략 */
     ]
     
     public init() {}
     
     public var body: some View {
         ZStack {
             ARContainer(
                 gameSettings: GameSettings(
                     gameCards: gameCards,
                     minimumSizeOfPlane: 4
                 ),
                 currentDetectedPlanes: $currentDetectedPlanes
             )
             .ignoresSafeArea()
             
             VStack {
                 Text("currentDetectedPlanes: \(currentDetectedPlanes)")
                 
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
    
    /// 현재 인식된 평면 수
    @Binding var currentDetectedPlanes: Int
    
    public init(gameSettings: GameSettings, currentDetectedPlanes: Binding<Int>) {
    public init(
        gameSettings: GameSettings,
        gamePhase: Binding<GamePhase>,
    ) {
        self.gameSettings = gameSettings
        self._gamePhage = gamePhase
        self._currentDetectedPlanes = currentDetectedPlanes
    }
    
    public func makeUIViewController(context: Context) -> ARContainerViewController {
        let viewController = ARContainerViewController(gameSettings: gameSettings)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ARContainerViewController, context: Context) {
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
    }
}
