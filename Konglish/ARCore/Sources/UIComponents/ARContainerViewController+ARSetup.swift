//
//  ARContainerViewController+ARFeatures.swift
//  ARCore
//
//  Created by 임영택 on 7/19/25.
//

import ARKit

/// ARView 초기화, 해제 로직
extension ARContainerViewController {
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
        // TODO: 다른 ARFeatureProvider 추가
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
}

/// ARSessionDelegate 구현
extension ARContainerViewController: ARSessionDelegate {
    /// 새로운 앵커가 추가되면 ARPlaneAnchor에 대해 시각화하는 엔티티를 추가한다
    public func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        logger.debug("🔨 new anchors have been added: \(anchors.count)")
        handleAddedAnchors(for: anchors)
    }
    
    /// 기존 앵커가 업데이트되면 이전에 추가한 시각화 엔티티를 제거하고 새로운 시각화 엔티티를 만든다
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        logger.debug("🔨 some anchors have been updated: \(anchors.count)")
        handleUpdatedAnchors(for: anchors)
    }
}
