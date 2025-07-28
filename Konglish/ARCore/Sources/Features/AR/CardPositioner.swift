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
import KonglishARProject

class CardPositioner: ARFeatureProvider {
    weak var arView: ARView?
    
    let logger = Logger.of("CardPositioner")
    
    init(arView: ARView) {
        self.arView = arView
    }
    
    /// ARPlaneAnchor에 카드를 추가한다.
    /// - Parameter context: 추가할 카드의 CardData와 대상 평면 앵커
    func operate(context: Input) -> Void {
        guard let arView = arView else {
            return
        }
        
        let cardEntity = createCardEntity(data: context.cardData)
        
        let anchorEntity = AnchorEntity(anchor: context.planeAnchor)
        anchorEntity.addChild(cardEntity)
        arView.scene.anchors.append(anchorEntity)
    }
    
    /// Transform을 기반으로 카드를 생성하고 AnchorEntity를 반환한다.
    /// - Parameter context: 추가할 카드의 CardData와 대상 transform
    /// - Returns: 생성된 AnchorEntity
    func createCardWithTransform(context: TransformInput) -> AnchorEntity? {
        guard let arView = arView else {
            return nil
        }
        
        let cardEntity = createCardEntity(data: context.cardData)
        let anchorEntity = AnchorEntity(world: context.transform)
        anchorEntity.addChild(cardEntity)
        
        return anchorEntity
    }
    
    private func createCardEntity(data: GameCard) -> Entity {
        guard let sceneEntity = try? Entity.load(named: "Scene", in: konglishARProjectBundle),
              let rootEntity = sceneEntity.children.first else {
            logger.warning("CardPositioner: failed to create card entity from Scene. A fallback entity will be used.")
            let fallbackEntity = ModelEntity()
            fallbackEntity.model = ModelComponent(
                mesh: .generateBox(size: [0.1, 0.01, 0.1]),
                materials: [SimpleMaterial(color: .red, isMetallic: false)]
            )
            return fallbackEntity
        }
        
        rootEntity.children.forEach { entity in
            if entity.name == "Card" {
                // 커스텀 컴포넌트 추가
                entity.components[CardComponent.self] = CardComponent(cardData: data)
                
                // 호버 컴포넌트 추가
                entity.components[HoverComponent.self] = HoverComponent(cardData: data)
            }
        }
        
        return sceneEntity
    }
    
    struct Input {
        let planeAnchor: ARPlaneAnchor
        let cardData: GameCard
    }
    
    struct TransformInput {
        let transform: simd_float4x4
        let cardData: GameCard
    }
}
