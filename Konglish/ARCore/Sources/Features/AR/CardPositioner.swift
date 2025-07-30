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
    
    private var cardParticleEmitter: ParticleEmitterComponent {
        var particleEmitter = ParticleEmitterComponent()
        particleEmitter.mainEmitter.birthRate = 300
        particleEmitter.mainEmitter.lifeSpan = 1.5
        particleEmitter.mainEmitter.size = 0.02
    
        particleEmitter.mainEmitter.color = .evolving(
            start: .single(UIColor(red: 0.1, green: 0.9, blue: 0.6, alpha: 0.6)),
            end: .single(UIColor(red: 0.1, green: 0.45, blue: 0.8, alpha: 0.0))
        )
        
        particleEmitter.emitterShape = .box
        particleEmitter.emitterShapeSize = [0.34, 0.001, 0.22]
        particleEmitter.emissionDirection = [0, 1, 0]
        particleEmitter.speed = 0.35
        particleEmitter.speedVariation = 0.08
        particleEmitter.mainEmitter.spreadingAngle = .pi * 0.1
        
        particleEmitter.mainEmitter.acceleration = [0, -0.1, 0]
        
        particleEmitter.isEmitting = false
        return particleEmitter
    }
    
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
                
                // 호버 컴포넌트 추가
                entity.components[HoverComponent.self] = HoverComponent(cardData: data)
                
                // 파티클 에미터 추가
                entity.components.set(cardParticleEmitter)
            }
        }
        
        return sceneEntity
    }
    
    struct Input {
        let planeAnchor: ARPlaneAnchor
        let cardData: GameCard
    }
}
