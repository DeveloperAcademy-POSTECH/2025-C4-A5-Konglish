//
//  ARContainerViewController+ARFeatures.swift
//  ARCore
//
//  Created by 임영택 on 7/19/25.
//

import ARKit

extension ARContainerViewController {
    // MARK: - Setup ARView
    func setupARView() {
        arView.environment.sceneUnderstanding.options = [
            .occlusion,
            .receivesLighting
        ]
        
        resetSession()
    }
    
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
    
    public func pauseSession() {
        arView.session.pause()
    }
}
