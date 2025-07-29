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
                
                // 호버 컴포넌트 추가
                entity.components[HoverComponent.self] = HoverComponent(cardData: data)
                
                // 가벼운 파티클 에미터 추가
                var particleEmitter = ParticleEmitterComponent()
                particleEmitter.mainEmitter.birthRate = 300
                particleEmitter.mainEmitter.lifeSpan = 1.5
                particleEmitter.mainEmitter.size = 0.02       
                
                // 부드러운 연한 골드 색상
                particleEmitter.mainEmitter.color = .evolving(
                    start: .single(UIColor(red: 0.1, green: 0.9, blue: 0.6, alpha: 0.6)),
                    end: .single(UIColor(red: 0.1, green: 0.45, blue: 0.8, alpha: 0.0))
                )
                
                // 카드 테두리에서 나오는 파티클 (얇은 직사각형 링 모양)
                particleEmitter.emitterShape = .box
                particleEmitter.emitterShapeSize = [0.34, 0.001, 0.22]  // 매우 얇은 박스로 카드 크기
                particleEmitter.emissionDirection = [0, 1, 0]            // 위쪽으로
                particleEmitter.speed = 0.35                             // 조금 더 빠르게
                particleEmitter.speedVariation = 0.08
                particleEmitter.mainEmitter.spreadingAngle = .pi * 0.1   // 좁은 퍼짐각도
                
                // 바깥쪽으로 살짝 퍼지도록
                particleEmitter.mainEmitter.acceleration = [0, -0.1, 0]  // 중력 효과
                
                particleEmitter.isEmitting = false
                entity.components.set(particleEmitter)
            }
        }
        
        return sceneEntity
    }
    
    struct Input {
        let planeAnchor: ARPlaneAnchor
        let cardData: GameCard
    }
}
