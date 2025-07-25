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
            guard let entity = entity as? CardEntity,
                  let dynamicTextureComponent = entity.components[DynamicTextureComponent.self] else { continue }
            
            let isHovering = dynamicTextureComponent.isHovering
            
            Task { @MainActor in
                let material = await createMaterial(
                    for: entity,
                    displayText: dynamicTextureComponent.attributedText,
                    isHovering: isHovering,
                    isFlipped: entity.isFlipped
                )
                
                entity.model?.materials = [material]
            }
        }
    }
    
    private func createMaterial(for entity: HasModel, displayText: NSAttributedString, isHovering: Bool, isFlipped: Bool) async -> Material {
        if isFlipped {
            return await createFrontMaterial(for: entity, displayText: displayText, isHovering: isHovering)
        } else {
            return createBackMaterial(for: entity, displayText: displayText, isHovering: isHovering)
        }
    }
    
    private func createFrontMaterial(for entity: HasModel, displayText: NSAttributedString, isHovering: Bool) async -> Material {
        // Load Cache
        if let cached = materialsCache.object(
            forKey: getMaterialCacheKey(entity: entity, isFlipped: true, isHovering: isHovering)
        ) {
            logger.debug("used cached material for entity=\(entity.id) isFlipped=\(true) isHovering=\(isHovering)")
            return cached.value
        }
        
        let backgroundColor = isHovering ? Self.hoveringBackgroundColor : Self.backgroundColor
        
        let image = await imageFrom(
            text: displayText,
            size: CGSize(
                width: Double(CardEntity.cardWidth) * 1000.0,
                height: Double(CardEntity.cardHeight) * 1000.0
            ),
            backgroundColor: backgroundColor
        )
        
        var material: Material
        do {
            material = try await createTextImageMaterial(from: image)
        } catch {
            let logMessage = "❌ DynamicTextureSystem: failed to create text image material"
                + "=> fallback texture will be applied."
                + "error:"
            logger.error("\(logMessage) \(error)")
            material = await SimpleMaterial(color: CardEntity.backgroundColor, isMetallic: false)
        }
        
        logger.debug("created front material for \(entity.id) isHovering=\(isHovering)")
        
        // Set Cache
        materialsCache.setObject(
            MaterialValue(value: material),
            forKey: getMaterialCacheKey(entity: entity, isFlipped: true, isHovering: isHovering)
        )
        
        return material
    }
    
    private func createBackMaterial(for entity: Entity, displayText: NSAttributedString, isHovering: Bool) -> Material {
        // Load Cache
        if let cached = materialsCache.object(
            forKey: getMaterialCacheKey(entity: entity, isFlipped: false, isHovering: isHovering)
        ) {
            logger.debug("used cached material for entity=\(entity.id) isFlipped=\(false) isHovering=\(isHovering)")
            return cached.value
        }
        
        let backgroundColor = isHovering ? Self.hoveringBackgroundColor : Self.backgroundColor
        let material = SimpleMaterial(color: backgroundColor, isMetallic: false)
        
        logger.debug("created back material for \(entity.id) isHovering=\(isHovering)")
        
        // Set Cache
        materialsCache.setObject(
            MaterialValue(value: material),
            forKey: getMaterialCacheKey(entity: entity, isFlipped: false, isHovering: isHovering)
        )
        
        return material
    }
    
    /// 특정 텍스트가 포함된 이미지를 생성한다
    // TODO: 하이파이 디자인에 맞게 카드 이미지, 폰트 등 세팅 필요함
    private func imageFrom(
        text: NSAttributedString,
        size: CGSize,
        textColor: UIColor = .black,
        backgroundColor: UIColor = backgroundColor
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // 배경 그리기
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 텍스트 크기 계산
            let textRect = CGRect(origin: .zero, size: size)
            text.draw(in: textRect)
        }
        
        return image
    }
    
    /// UIImage를 CGImage로 변환하고, RealityKit 텍스쳐로 반환한다.
    private func createTextImageMaterial(from image: UIImage) async throws -> Material {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "CGImage 변환 실패"])
        }

        let texture = try await TextureResource.generate(from: cgImage, withName: nil, options: .init(semantic: .normal, compression: .default))
        // CAUTION: Deprecated되어 `'init(image:withName:options:)'`를 사용하라는 경고가 발생하지만 사용하면 BAD_ACCESS 예외가 발생
        
        var material = SimpleMaterial()
        material.color = .init(texture: MaterialParameters.Texture(texture))
        
        return material
    }
    
    private func getMaterialCacheKey(entity: Entity, isFlipped: Bool, isHovering: Bool) -> NSString {
        NSString(string: "\(entity.id)_\(isFlipped ? "Flipped" : "Normal")_\(isHovering ? "Hovering" : "Normal")")
    }
}

fileprivate class MaterialValue: NSObject {
    let value: Material
    
    init(value: Material) {
        self.value = value
    }
}
