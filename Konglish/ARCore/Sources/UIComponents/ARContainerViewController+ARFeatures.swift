//
//  ARContainerViewController+ARFeatures.swift
//  ARCore
//
//  Created by 임영택 on 7/19/25.
//

import ARKit

extension ARContainerViewController {
    // MARK: - Setup ARView
    
    /// 처음 ARView를 초기화한다
    func setupARView() {
        arView.environment.sceneUnderstanding.options = [
            .occlusion,
            .receivesLighting
        ]
        
        resetSession()
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
    }
    
    /// 현재 ARSession을 멈춘다
    public func pauseSession() {
        arView.session.pause()
    }
}
