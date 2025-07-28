//
//  ARContainerViewController+PlaneDetection.swift
//  ARCore
//
//  Created by 임영택 on 7/19/25.
//

import ARKit
import RealityKit

/// 인식 평면 시각화 로직
extension ARContainerViewController {
    /// 평면 인식을 시작한다.
    public func startDetectingPlane() {
        gamePhase = .scanning
    }
    
    /// 인식된 평면을 시각화하는 엔티티를 제거한다
    func removeDetectedPlaneEntities() {
        detectedPlaneEntities.values.forEach { $0.removeFromParent() }
        detectedPlaneEntities = [:]
    }
    
    /// 새로운 인식 평면을 시각화하는 엔티티를 씬에 추가한다.
    /// - Parameter planeAnchor: 새로 인식한 평면의 앵커
    fileprivate func addPlaneVisualization(planeAnchor: ARPlaneAnchor, animate: Bool) {
        let addedEntity = self.planeVisualizer?.operate(context: .init(planeAnchor: planeAnchor, animate: animate))
        detectedPlaneEntities[planeAnchor] = addedEntity
    }
    
    /// 새로운 인식한 평면의 크기가 충분한지 검사한다. 최소 면적은 GameSettings의 minimumSizeOfPlane에 지정한다.
    /// - Parameter planeAnchor: 새로 인식한 평면의 앵커
    /// - Returns: 검사 결과. true이면 최소 넓이보다 큼. false이면 최소 넒이보다 작음.
    fileprivate func checkNewPlaneSize(planeAnchor: ARPlaneAnchor) -> Bool {
        let width = planeAnchor.planeExtent.width
        let height = planeAnchor.planeExtent.height
        
        return width * height > gameSettings.minimumSizeOfPlane
    }
    
    /// 지정된 개수의 평면을 모두 찾았는지 검사한다. 평면 개수는 GameSettings의 numberOfCards에 지정한다.
    fileprivate func checkAllPlanesAttached() -> Bool {
        return detectedPlaneEntities.keys.count >= gameSettings.numberOfCards
    }
    
    func handleAddedAnchors(for anchors: [ARAnchor]) {
        guard (gamePhase == .scanning || gamePhase == .scanned), !checkAllPlanesAttached() else {
            return
        }
        
        let planeAnchors = anchors.compactMap { anchor in
            if let planeAnchor = anchor as? ARPlaneAnchor {
                return planeAnchor
            }
            return nil
        }
        
        for planeAnchor in planeAnchors {
            if checkAllPlanesAttached() {
                break
            }
            
            if !checkNewPlaneSize(planeAnchor: planeAnchor) {
                continue
            }
            
            addPlaneVisualization(planeAnchor: planeAnchor, animate: true)
            delegate?.arContainerDidFindPlaneAnchor(self)
            if checkAllPlanesAttached() {
                gamePhase = .scanned  // 모든 평면 감지 완료 시 scanned 상태로 변경
                delegate?.arContainerDidFindAllPlaneAnchor(self)
            }
        }
    }
    
    func handleRemovedAnchors(for anchors: [ARAnchor]) {
        
        guard (gamePhase == .scanning || gamePhase == .scanned) else {
            return
        }
        
        let planeAnchors = anchors.compactMap { $0 as? ARPlaneAnchor }
        
        for planeAnchor in planeAnchors {
            if let planeEntity = detectedPlaneEntities[planeAnchor] {
                planeEntity.removeFromParent()
                detectedPlaneEntities.removeValue(forKey: planeAnchor)
                // 평면이 부족해지면 다시 scanning 상태로 변경
                if gamePhase == .scanned && !checkAllPlanesAttached() {
                    gamePhase = .scanning
                }
                
                // 다시 스캔 가능하게 delegate 호출
                delegate?.arContainerDidLosePlaneAnchor(self)
            }
        }
    }
    
    func handleUpdatedAnchors(for anchors: [ARAnchor]) {
        guard (gamePhase == .scanning || gamePhase == .scanned) else {
            return
        }
        
        let planeAnchors = anchors.compactMap { anchor in
            if let planeAnchor = anchor as? ARPlaneAnchor {
                return planeAnchor
            }
            return nil
        }
        
        for planeAnchor in planeAnchors {
            if let planeEntity = detectedPlaneEntities[planeAnchor] {
                // 이미 존재하는 엔티티인 경우 제거하고 다시 그린다
                planeEntity.removeFromParent()
                addPlaneVisualization(planeAnchor: planeAnchor, animate: false)
            } else {
                // 아직 존재하지 않는 경우 이전에 인식되었으나 면적이 좁아 추가되지 않은 경우로,
                // 다시 면적을 검사하여 추가한다.
                if checkAllPlanesAttached() {
                    break
                }
                
                if !checkNewPlaneSize(planeAnchor: planeAnchor) {
                    break
                }
                
                addPlaneVisualization(planeAnchor: planeAnchor, animate: true)
                delegate?.arContainerDidFindPlaneAnchor(self)
                if checkAllPlanesAttached() {
                    gamePhase = .scanned  // 모든 평면 감지 완료 시 scanned 상태로 변경
                    delegate?.arContainerDidFindAllPlaneAnchor(self)
                }
            }
        }
    }
}
