
//
//  CentralPortalVisualizer.swift
//  ARCore
//
//  Created by 길지훈 on 7/28/25.
//

import ARKit
import RealityKit
import os.log

class CentralPortalVisualizer: ARFeatureProvider {
    weak var arView: ARView?
    
    let logger = Logger.of("CentralPortalVisualizer")
    private var portalWorldScene: Entity?

    init(arView: ARView) {
        self.arView = arView
        loadPortalAssets()
    }

    // ARView 생성 시, 에셋을 미리 로드함
    private func loadPortalAssets() {
        Task {
            do {
                if let portalWorldURL = Bundle.module.url(forResource: "skybox1", withExtension: "usdz") {
                    portalWorldScene = try await Entity.init(contentsOf: portalWorldURL)
                    logger.debug("✅ skybox1.usdz 로드 성공!")
                } else {
                    logger.error("❌ skybox1.usdz 파일을 찾을 수 없습니다.")
                }
            } catch {
                logger.error("❌ skybox1.usdz 로드 실패: \(error.localizedDescription)")
            }
        }
    }
    
    /// 화면 중앙 Hit-Test 결과를 기반으로 포털을 생성하고 씬에 추가한다.
    /// - Parameter context: ARAnchor
    /// - Returns: 생성된 포털 AnchorEntity. 실패 시 nil.
    func operate(context: Input) -> AnchorEntity? {
        guard let arView = arView, let portalWorldScene = portalWorldScene?.clone(recursive: true) else {
            logger.error("ARView 또는 portalWorldScene이 준비되지 않았습니다.")
            return nil
        }
        
        let arAnchor = context.arAnchor
        
        // 1. World 생성
        let world = Entity()
        world.components.set(WorldComponent())
        
        // PortalWorld.usdz 콘텐츠 조정
        portalWorldScene.transform.translation.z = -2.0
        portalWorldScene.transform.rotation = simd_quatf(angle: .pi/2, axis: [-1, 0, 0])
        
        world.addChild(portalWorldScene)
        
        // 2. Portal 생성 - 원형으로
        let portalMesh = MeshResource.generatePlane(width: 1.8, depth: 2.0, cornerRadius: 0.2)
        let portal = ModelEntity(mesh: portalMesh, materials: [PortalMaterial()])
        portal.components.set(PortalComponent(target: world))
        portal.transform.translation.z = 0.05 // 포털 평면을 앵커 원점으로부터 약간 앞으로 밀어냄
        
        
        // 3. 동화 같은 반짝이 파티클 ✨
        let sparkleEntity = Entity()
        var sparkleEmitter = ParticleEmitterComponent()
        
        // 가벼운 반짝이 파티클 설정
        sparkleEmitter.mainEmitter.birthRate = 200
        sparkleEmitter.mainEmitter.lifeSpan = 2.5
        sparkleEmitter.mainEmitter.size = 0.02
        
        // 동화 같은 파스텔 색상
        sparkleEmitter.mainEmitter.color = .evolving(
            start: .single(UIColor(red: 1.0, green: 0.9, blue: 0.6, alpha: 0.8)),  // 연한 골드
            end: .single(UIColor(red: 1.0, green: 0.7, blue: 0.9, alpha: 0.0))     // 연한 핑크로 사라짐
        )
        
        // 포털 주변에서 살짝 퍼져나가게
        sparkleEmitter.emitterShape = .sphere
        sparkleEmitter.emitterShapeSize = [1, 1, 1]
        
        // 위로 살짝 떠오르는 느낌
        sparkleEmitter.emissionDirection = [0, 0.5, 0]
        sparkleEmitter.speed = 0.1
        sparkleEmitter.speedVariation = 0.05
        sparkleEmitter.mainEmitter.spreadingAngle = .pi * 0.8      // 퍼짐 정도
        
        sparkleEntity.components.set(sparkleEmitter)
        sparkleEntity.transform.translation = [0, 0, 0.03]         // 포털 바로 앞
        
        // 4. 앵커에 추가
        let anchor = AnchorEntity(anchor: arAnchor) // ARAnchor를 부모로 갖도록 변경
        anchor.addChild(world)
        anchor.addChild(portal)
        anchor.addChild(sparkleEntity)
        
        
        
        // 초기 스케일을 0으로 설정하여 보이지 않게 시작
        anchor.transform.scale = .zero
        
        arView.scene.addAnchor(anchor)
        
        // 애니메이션을 통해 스케일을 1로 키움
        var transform = anchor.transform
        transform.scale = [1, 1, 1]
        anchor.move(to: transform, relativeTo: nil, duration: 1.5, timingFunction: .easeOut)
        
        logger.debug("✅ 포털 생성 완료!")
        return anchor
    }
    
    struct Input {
        let arAnchor: ARAnchor
    }
}
