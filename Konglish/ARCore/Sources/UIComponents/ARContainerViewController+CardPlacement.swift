//
//  ARContainerViewController+CardPlacement.swift
//  ARCore
//
//  Created by 임영택 on 7/21/25.
//

import Foundation
import RealityKit

extension ARContainerViewController {
    /// 인식된 평면에 카드를 배치한다.
    /// 인식된 평면 수가 충분하지 않으면 `ARCoreError.insufficientPlanes` 예외를 던진다.
    public func placeCards() throws {
        let detectedPlaneAnchors = detectedPlaneEntities.keys
        let detectedPlaneVisualizations = detectedPlaneEntities.values
        
        // 인식된 평면 수가 충분한지 검사한다
        guard detectedPlaneAnchors.count >= gameSettings.gameCards.count else {
            logger.error("❌ insufficient planes. current number of planes: \(detectedPlaneAnchors.count) required: \(self.gameSettings.gameCards.count)")
            throw ARCoreError.insufficientPlanes
        }
        
        gamePhase = .scanned
        
        // 인식된 평면 엥커에 카드를 배치한다
        detectedPlaneAnchors.enumerated().forEach { (index, planeAnchor) in
            cardPositioner?.operate(context: .init(
                planeAnchor: planeAnchor,
                cardData: gameSettings.gameCards[index]
            ))
        }
        
        // 기존 평면 시각화 엔티티를 제거한다
        detectedPlaneVisualizations.forEach { anchorEntity in
            anchorEntity.children.removeAll()
            anchorEntity.removeFromParent()
        }
    }
}
