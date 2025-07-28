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
    
    /// 화면 중앙을 기준으로 레이캐스트를 수행하여 수직 평면에 포털을 생성한다.
    public func createPortalAtCenter() {
        guard let portalVisualizer = self.portalVisualizer else {
            logger.error("CentralPortalVisualizer가 초기화되지 않았습니다.")
            return
        }
        
        // 화면 중앙에서 수직 평면을 대상으로 레이캐스트 수행
        let results = arView.raycast(from: arView.center, allowing: .estimatedPlane, alignment: .vertical)
        
        if let firstResult = results.first {
            logger.debug("✅ 레이캐스트 성공: 수직 평면을 찾았습니다.")
            
            // 현재 감지된 모든 평면의 위치를 저장 -> 다시 해당 위치로 카드를 배치하기 위함.
            for (planeAnchor, _) in detectedPlaneEntities {
                savedPlaneTransforms[planeAnchor.identifier] = planeAnchor.transform
            }
            logger.debug("✅ 모든 평면 위치 저장 완료: \(self.savedPlaneTransforms.count)개")
            
            // 평면 ARAnchor들을 ARSession에서 제거하여 ARKit의 자동 업데이트 중단
            for (planeAnchor, _) in detectedPlaneEntities {
                arView.session.remove(anchor: planeAnchor)
            }
            logger.debug("✅ 모든 평면 ARAnchor 제거 완료")
            
            // ARAnchor 생성 및 ARSession에 추가
            let arAnchor = ARAnchor(transform: firstResult.worldTransform)
            arView.session.add(anchor: arAnchor)
            
            // CentralPortalVisualizer를 사용해 포털 생성
            let portalAnchor = portalVisualizer.operate(context: .init(arAnchor: arAnchor))
            
            if let portalAnchor = portalAnchor {
                // 포털 생성 성공
                logger.debug("포털 생성이 성공적으로 완료되었습니다.")
                self.gamePhase = .portalCreated
                
                // 평면들이 포털로 빨려 들어가는 애니메이션
                let animationDuration: TimeInterval = 3.0
                // 애니메이션 목표 지점: ARAnchor의 실제 월드 위치
                let animationTargetWorldPosition = arAnchor.transform.columns.3

                for (_, planeEntity) in detectedPlaneEntities {
                    // 평면 엔티티의 현재 transform을 유지하면서 위치만 변경
                    var targetTransform = planeEntity.transform
                    
                    // 목표 위치를 ARAnchor의 실제 월드 위치로 설정
                    targetTransform.translation = SIMD3<Float>(animationTargetWorldPosition.x, animationTargetWorldPosition.y, animationTargetWorldPosition.z)
                    
                    // 애니메이션의 끝에 스케일을 0으로 만들기
                    targetTransform.scale = .zero
                    
                    // 애니메이션 적용 - 월드 좌표계 기준
                    planeEntity.move(
                        to: targetTransform,
                        relativeTo: nil,
                        duration: animationDuration,
                        timingFunction: .easeOut
                    )
                }
                
                // 애니메이션 완료 후 평면 엔티티 제거
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    self.removeDetectedPlaneEntities()
                    self.logger.debug("✅ 모든 평면 시각화 엔티티 제거 완료 (애니메이션 후)")
                }
                
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
