//
//  ARContainerViewController+CardFlipper.swift
//  ARCore
//
//  Created by 길지훈 on 7/24/25.
//

import ARKit
import RealityKit

/// 카드 감지 + 회전을 결합한 카드 뒤집기 기능
extension ARContainerViewController {
    
    /// 화면 중앙에서 카드 감지 후, 뒤집기
    func flipCardAtCenter() -> UUID? {
        // 기존 CardDetector로 카드 감지
        guard let cardEntity = cardDetector?.operate(context: CardDetector.Input()) else {
            return nil
        }
        
        // 카드 ID 추출
        guard let cardId = cardEntity.cardData?.id else {
            return nil
        }
        
        // 완료된 카드는 뒤집지 않음
        guard !cardEntity.isCompleted else {
            logger.info("이미 완료된 카드라서 뒤집지 않습니다: \(cardId)")
            return nil
        }
        
        // 기존 CardRotator로 카드 뒤집기
        cardRotator?.operate(context: CardRotator.Input(cardEntity: cardEntity))
        
        return cardId
    }
}
