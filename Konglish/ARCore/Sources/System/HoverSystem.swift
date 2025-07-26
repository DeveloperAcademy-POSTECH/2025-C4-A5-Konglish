//
//  HoverSystem.swift
//  ARCore
//
//  Created by 임영택 on 7/24/25.
//

import RealityKit
import UIKit
import os.log

struct HoverSystem: System {
    // MARK: - Type Properties
    private static let query = EntityQuery(where: .has(HoverComponent.self))
    private static let backgroundColor = UIColor(named: "primary01") ?? .blue
    private static let hoveringBackgroundColor: UIColor = .red
    
    // MARK: - Properties
    private let logger = Logger.of("HoverSystem")
    
    init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            let isHovering = entity.components[HoverComponent.self]?.isHovering ?? false
            
            entity.children.forEach { child in
                if child.name == "Cube" {
                    if let modelEntity = child.children.first as? ModelEntity { // Cube_001
                        if isHovering {
                            modelEntity.components[ParticleEmitterComponent.self]?.isEmitting = true
                        } else {
                            modelEntity.components[ParticleEmitterComponent.self]?.isEmitting = false
                        }
                    }
                }
            }
        }
    }
}
