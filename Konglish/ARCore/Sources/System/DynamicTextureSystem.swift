//
//  DynamicTextureSystem.swift
//  ARCore
//
//  Created by 임영택 on 7/24/25.
//

import RealityKit
import UIKit
import os.log

class DynamicTextureSystem: System {
    // MARK: - Type Properties
    private static let query = EntityQuery(where: .has(DynamicTextureComponent.self))
    private static let backgroundColor = UIColor(named: "primary01") ?? .blue
    private static let hoveringBackgroundColor: UIColor = .red
    
    // MARK: - Properties
    private var materialsCache = NSCache<NSString, MaterialValue>()
    private let logger = Logger.of("DynamicTextureSystem")
    
    required init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            guard entity.components.has(DynamicTextureComponent.self) else {
                logger.debug("This is not a dynamic texture card entity")
                continue
            }
            
            let isHovering = entity.components[DynamicTextureComponent.self]?.isHovering ?? false
            
            entity.children.forEach { child in
                if child.name == "Cube" {
                    if let modelEntity = child.children.first as? ModelEntity { // Cube_001
                        if var pbMaterial = modelEntity.model?.materials.first as? PhysicallyBasedMaterial {
                            if isHovering {
                                pbMaterial.baseColor = .init(tint: .red)
                            } else {
                                pbMaterial.baseColor = entity.components[DynamicTextureComponent.self]?.originalBaseColor ?? .init(tint: .blue)
                            }
                            modelEntity.model?.materials[0] = pbMaterial
                        }
                    }
                }
            }
        }
    }
    
    fileprivate class MaterialValue: NSObject {
        let value: Material
        
        init(value: Material) {
            self.value = value
        }
    }
}
