//
//  CardRotator.swift
//  ARCore
//
//  Created by 길지훈 on 7/24/25.
//

import RealityKit
import ARKit
import os.log

/// AR 카드를 뒤집는(회전) 기능
///
/// ## 주요 기능
/// - 양방향 카드 회전 (뒷면 ↔ 앞면)
/// - 완료된 카드 회전 방지
/// - 부드러운 회전 애니메이션 적용
///
/// ## 사용법
/// ```swift
/// let rotator = CardRotator(arView: myARView)
/// rotator.operate(context: CardRotator.Input(cardEntity: myCardEntity))
/// // 이미 뒤집힌 카드는 자동으로 무시되게!
/// ```
class CardRotator: ARFeatureProvider {
    
    weak var arView: ARView?
    let logger = Logger.of("CardRotator")
    
    init(arView: ARView) {
        self.arView = arView
        logger.info("CardRotator 초기화됨.")
    }
    
    func operate(context: Input) {
        let cardEntity = context.cardEntity
        
        // 완료된 카드는 회전하지 않음
        guard !cardEntity.isCompleted else {
            logger.info("이미 완료된 카드라서 회전하지 않습니다.")
            return
        }
        
        // 카드 회전 실행 (양방향)
        rotateCard(cardEntity)
    }
    
    private func rotateCard(_ cardEntity: CardEntity) {
        // 목표 회전 상태 결정
        let targetRotation: simd_quatf
        let newFlippedState: Bool
        
        if cardEntity.isFlipped {
            // 앞면 → 뒷면 (실패 후 되돌리기)
            targetRotation = simd_quatf(angle: 0, axis: [0, 1, 0])
            newFlippedState = false
            logger.info("카드를 뒷면으로 되돌립니다.")
        } else {
            // 뒷면 → 앞면 (처음 시도)
            targetRotation = simd_quatf(angle: .pi, axis: [0, 1, 0])
            newFlippedState = true
            logger.info("카드를 앞면으로 뒤집습니다.")
        }
        
        // 회전 애니메이션 생성
        let rotationAnimation = try! AnimationResource.generate(
            with: FromToByAnimation<Transform>(
                from: cardEntity.transform,
                to: Transform(
                    scale: cardEntity.transform.scale,
                    rotation: targetRotation,
                    translation: cardEntity.transform.translation
                ),
                duration: 0.5,
                timing: .easeInOut
            )
        )
        
        // 애니메이션 실행
        cardEntity.playAnimation(rotationAnimation)
        
        // 회전 상태 업데이트
        cardEntity.isFlipped = newFlippedState
    }
    
    struct Input {
        let cardEntity: CardEntity
    }
    
    typealias Output = Void
}
