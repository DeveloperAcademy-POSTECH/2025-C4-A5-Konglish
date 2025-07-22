//
//  CardDetector.swift
//  ARCore
//
//  Created by 길지훈 on 7/23/25.
//

import RealityKit
import ARKit
import os.log

/// 화면 중앙의 AR 카드를 감지하는 기능 제공자
///
/// ## 주요 기능
/// - 화면 중앙 좌표에서 raycast를 통한 카드 감지
/// - 감지된 카드의 고유 ID (UUID) 반환
///
/// ## 사용법
/// ```swift
/// let detector = CardDetector(arView: myARView)
/// let cardId = detector.operate(context: CardDetector.Input())
///
/// if let cardId = cardId {
///     // 카드 감지됨 - 프로그레스 시작
/// } else {
///     // 카드 없음 - 무반응
/// }
/// ```
///
class CardDetector: ARFeatureProvider {
    
    weak var arView: ARView?
    let logger = Logger.of("CardDetector")
    
    init(arView: ARView) {
        self.arView = arView
        logger.info("CardDetector 초기화됨.")
    }
    
    func operate(context: Input) -> UUID? {
        return findCardAtCenter()
    }
    
    private func findCardAtCenter() -> UUID? {
        guard let arView = arView else { return nil }
        
        // Raycast 동작
        let centerPoint = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
        
        // .estimatedPlane - ARKit이 추정한 평면들 (바닥, 벽, 테이블 등)
        let results = arView.raycast(from: centerPoint, allowing: .estimatedPlane, alignment: .any)
        
        for result in results {
            // columns.3 = raycast가 평면에 맞은 3D 월드 좌표
            let worldPosition = result.worldTransform.columns.3
            let anchor = result.anchor
            
            for sceneAnchor in arView.scene.anchors {
                if let anchorEntity = sceneAnchor as? AnchorEntity,
                   anchorEntity.anchor?.anchorIdentifier == anchor?.identifier {
                    
                    for child in anchorEntity.children {
                        if let cardEntity = child as? CardEntity {
                            return cardEntity.cardData?.id
                        }
                    }
                }
            }
        }
        
        return nil
    }
   
    
    struct Input {
        //
    }
    
    typealias Output = UUID?
}
