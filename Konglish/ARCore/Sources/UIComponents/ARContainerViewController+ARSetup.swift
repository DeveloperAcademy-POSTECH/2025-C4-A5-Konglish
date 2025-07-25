//
//  ARContainerViewController+ARFeatures.swift
//  ARCore
//
//  Created by 임영택 on 7/19/25.
//

import ARKit
import RealityKit

/// ARView 초기화, 해제 로직
extension ARContainerViewController {
    // MARK: - Setup ARView
    
    /// 처음 ARView를 초기화한다
    func setupARView() {
        DynamicTextureSystem.registerSystem()
        
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
        self.cardPositioner = CardPositioner(arView: arView)
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
        
        arView.scene.subscribe(to: SceneEvents.Update.self) { [weak self]  event in
            self?.updateHoveringState(event: event)
        }.store(in: &sceneSubscriptions)
        
        logger.info("✅ ARSession have been started")
    }
    
    /// 현재 ARSession을 멈춘다
    public func pauseSession() {
        removeDetectedPlaneEntities()
        arView.session.pause()
    }
    
    
    /// 씬이 업데이트될 때 실행되어 호버링 여부를 업데이트한다
    private func updateHoveringState(event: SceneEvents.Update) {
        let observeCycle = 0.5
        
        // 누적 시간 증가
        self.observeHoveringAccumulatedTime += event.deltaTime

        // 일정 주기(`observeCycle`)마다 수행
        guard self.observeHoveringAccumulatedTime > observeCycle else {
            return
        }
        self.observeHoveringAccumulatedTime = 0  // 리셋
        
        let entityQuery = EntityQuery(where: .has(DynamicTextureComponent.self))
        self.arView.scene.performQuery(entityQuery)
            .compactMap { havingCardComponent in
                if let cardEntity = havingCardComponent as? CardEntity {
                    return cardEntity
                }
                return nil
            }
            .forEach { (cardEntity: CardEntity) in
                cardEntity.components[DynamicTextureComponent.self]?.isHovering = false
            }
        
        let center = CGPoint(x: self.arView.bounds.midX, y: self.arView.bounds.midY)
        let hits = self.arView.hitTest(center)

        for result in hits {
            if let cardEntity = result.entity as? CardEntity {
                cardEntity.components[DynamicTextureComponent.self]?.isHovering = true
            }
        }
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
