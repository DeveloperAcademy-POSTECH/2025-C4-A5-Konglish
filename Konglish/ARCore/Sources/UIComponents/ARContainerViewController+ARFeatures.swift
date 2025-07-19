//
//  ARContainerViewController+ARFeatures.swift
//  ARCore
//
//  Created by 임영택 on 7/19/25.
//

import ARKit

extension ARContainerViewController {
    // MARK: - Computed Variables
    
    /// 인식된 평면 앵커의 개수
    public var planeAnchorsCount: Int {
        return arView.session.currentFrame?.anchors.filter { $0 is ARPlaneAnchor }.count ?? 0
    }
    
    // MARK: - Setup ARView
    
    /// 처음 ARView를 초기화한다
    func setupARView() {
        arView.session.delegate = self
        
        arView.environment.sceneUnderstanding.options = [
            .occlusion,
            .receivesLighting
        ]
        
        prepareFeatureProviders()
        
        resetSession()
        
        logger.info("✅ ARView have been setup")
    }
    
    func prepareFeatureProviders() {
        self.planeVisualizer = PlaneVisualizer(arView: arView)
    }
    
    /// 현재 ARSession을 리셋한다
    public func resetSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.vertical]
        configuration.sceneReconstruction = .mesh
        
        if isDebugModeEnabled {
            arView.debugOptions = [
                .showAnchorGeometry,
                .showFeaturePoints,
                .showWorldOrigin,
                .showSceneUnderstanding
            ]
        }
        
        arView.session.run(configuration)
        
        logger.info("✅ ARSession have been started")
    }
    
    /// 현재 ARSession을 멈춘다
    public func pauseSession() {
        removeDetectedPlaneEntities()
        arView.session.pause()
    }
    
    /// 인식된 평면을 시각화하는 엔티티를 제거한다
    func removeDetectedPlaneEntities() {
        detectedPlaneEntities.values.forEach { $0.removeFromParent() }
        detectedPlaneEntities = [:]
    }
}

extension ARContainerViewController: ARSessionDelegate {
    /// 새로운 앵커가 추가되면 ARPlaneAnchor에 대해 시각화하는 엔티티를 추가한다
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        logger.debug("🔨 new anchors have been added: \(anchors.count)")
        
        anchors.compactMap { anchor in
            if let planeAnchor = anchor as? ARPlaneAnchor {
                return planeAnchor
            }
            return nil
        }
        .forEach { planeAnchor in
            let addedEntity = self.planeVisualizer?.operate(context: .init(planeAnchor: planeAnchor, animate: true))
            detectedPlaneEntities[planeAnchor.identifier] = addedEntity
        }
        
        delegate?.arContainerDidFindPlaneAnchor(self)
    }
    
    /// 기존 앵커가 업데이트되면 이전에 추가한 시각화 엔티티를 제거하고 새로운 시각화 엔티티를 만든다
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        logger.debug("🔨 some anchors have been updated: \(anchors.count)")
        
        let planeAnchors = anchors.compactMap { anchor in
            if let planeAnchor = anchor as? ARPlaneAnchor {
                return planeAnchor
            }
            return nil
        }
        
        planeAnchors.forEach { planeAnchor in
            if let planeEntity = detectedPlaneEntities[planeAnchor.identifier] {
                planeEntity.removeFromParent()
                
                let addedEntity = self.planeVisualizer?.operate(context: .init(planeAnchor: planeAnchor, animate: false))
                detectedPlaneEntities[planeAnchor.identifier] = addedEntity
            }
        }
    }
}
