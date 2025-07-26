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
                
                // 원래 머테리얼 찾기
                if let cubeEntity = entity.children.first { // Cube
                    if let cubeModelEntity = cubeEntity.children.first as? ModelEntity {
                        logger.debug("original material found: \(cubeModelEntity.model?.materials.first?.name ?? "N/A")")
                        if let originalMaterial = cubeModelEntity.model?.materials.first as? PhysicallyBasedMaterial {
                            // 동적 텍스쳐 지정을 위한 컴포넌트
                            entity.components[DynamicTextureComponent.self] = DynamicTextureComponent(cardData: data, originalBaseColor: originalMaterial.baseColor)
                        } else {
                            logger.error("original material not found. faliled to set DynamicTextureComponent")
                        }
                    }
                }
            }
        }
        
        return sceneEntity
    }
    
    struct Input {
        let planeAnchor: ARPlaneAnchor
        let cardData: GameCard
    }
}
