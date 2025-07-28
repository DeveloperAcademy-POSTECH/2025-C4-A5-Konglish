//
//  ARContainerViewController+Portal.swift
//  ARCore
//
//  Created by 길지훈 on 7/28/25.
//

import ARKit
import RealityKit

/// 포털 생성 및 관리 로직
extension ARContainerViewController {
    
    /// 화면 중앙을 기준으로 Hit-Test를 수행하여 수직 평면에 포털을 생성한다.
    public func createPortalAtCenter() {
        guard let portalVisualizer = self.portalVisualizer else {
            logger.error("CentralPortalVisualizer가 초기화되지 않았습니다.")
            return
        }
        
        // 화면 중앙에서 수직 평면을 대상으로 레이캐스트 수행
        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .vertical)
        
        if let firstResult = results.first {
            logger.debug("✅ Hit-Test 성공: 수직 평면을 찾았습니다.")
            
            // ARAnchor 생성 및 ARSession에 추가
            let arAnchor = ARAnchor(transform: firstResult.worldTransform)
            arView.session.add(anchor: arAnchor)
            
            // CentralPortalVisualizer를 사용해 포털 생성
            let portalAnchor = portalVisualizer.operate(context: .init(arAnchor: arAnchor))
            
            if portalAnchor != nil {
                // 포털 생성 성공
                logger.debug("포털 생성이 성공적으로 완료되었습니다.")
                self.gamePhase = .portalCreated
                // TODO: 여기에 다음 단계(평면 위치 저장, 애니메이션 등)를 위한 로직 추가
                
            } else {
                // 포털 생성 실패
                logger.error("Hit-Test는 성공했으나 포털 생성에 실패했습니다.")
            }
            
        } else {
            logger.warning("❌ Hit-Test 실패: 화면 중앙에 수직 평면이 없습니다.")
            // TODO: 사용자에게 피드백을 주는 로직 (예: 토스트 메시지)
        }
    }
}
