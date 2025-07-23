//
//  CardPositioner.swift
//  ARCore
//
//  Created by 임영택 on 7/21/25.
//

import Foundation
import ARKit
import RealityKit
import os.log

class CardPositioner: ARFeatureProvider {
    weak var arView: ARView?
    
    let logger = Logger.of("PlaneVisualizer")
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    /// ARPlaneAnchor에 카드를 추가한다.
    /// - Parameter context: 추가할 카드의 CardData와 대상 평면 앵커
    func operate(context: Input) -> Void {
        guard let arView = arView else {
            return
        }
        
        let anchorEntity = AnchorEntity(anchor: context.planeAnchor)
        
        let cardEntity = CardEntity(
            cardData: context.cardData, position: .init(0, 0, 0)
        )
        
        anchorEntity.addChild(cardEntity)
        arView.scene.anchors.append(anchorEntity)
    }
    
    struct Input {
        let planeAnchor: ARPlaneAnchor
        let cardData: GameCard
    }
}
