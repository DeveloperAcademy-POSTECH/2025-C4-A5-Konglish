//
//  DynamicContentSystem.swift
//  ARCore
//
//  Created by 임영택 on 7/26/25.
//

import Foundation
import RealityKit
import UIKit
import os.log

struct DynamicCardContentSystem: System {
    // MARK: - Type Properties
    /// 대상 엔티티 쿼리
    private static let query = EntityQuery(where: .has(CardComponent.self))
    
    /// 카드 너비
    static let cardWidth: Double = 0.3
    
    /// 카드 높이
    static let cardHeight: Double = 0.18
    
    /// 너비와 높이 가지고 이미지 해상도를 계산할 떄 사용하는 인자
    static let scaleFactor: Double = 1000.0
    
    static let cardBackgroundColor: UIColor = UIColor(red: 0.855, green: 0.855, blue: 0.571, alpha: 1.0)
    
    // MARK: - Properties
    /// 머테리얼 생성 후 캐시
    private var materialsCache = NSCache<NSString, MaterialValue>()
    
    /// 로거
    private let logger = Logger.of("DynamicCardContentSystem")
    
    init(scene: Scene) { }
    
    func update(context: SceneUpdateContext) {
        for entity in context.entities(
            matching: Self.query,
            updatingSystemWhen: .rendering
        ) {
            entity.children.forEach { child in
                if child.name == "Plane" {
                    if let modelEntity = child.children.first as? ModelEntity { // Nested `Plane`
                        let contentText = entity.components[CardComponent.self]?.attributedText ?? NSAttributedString()
                        
                        Task { @MainActor in
                            modelEntity.model?.materials = [
                                await createContentMaterial(for: modelEntity, displayText: contentText)
                            ]
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func createContentMaterial(for entity: HasModel, displayText: NSAttributedString) async -> Material {
        // Load Cache
        if let cached = materialsCache.object(
            forKey: getMaterialCacheKey(entity: entity)
        ) {
            logger.debug("used cached material for entity=\(entity.id)")
            return cached.value
        }
        
        let image = imageFrom(
            text: displayText,
            font: .systemFont(ofSize: 24),
            size: CGSize(
                width: Self.cardWidth * Self.scaleFactor,
                height: Self.cardHeight * Self.scaleFactor
            )
        )
        
        var material: Material
        do {
            let baseMaterial = extractBaseMaterial(from: entity) as? PhysicallyBasedMaterial
            material = try await convertImageToMaterial(from: image, baseMaterial: baseMaterial)
        } catch {
            let logMessage = "❌ DynamicTextureSystem: failed to create text image material"
                + "=> fallback texture will be applied."
                + "error:"
            logger.error("\(logMessage) \(error)")
            material = SimpleMaterial(color: .blue, isMetallic: false)
        }
        
        logger.debug("created front material for \(entity.id)")
        
        // Set Cache
        materialsCache.setObject(
            MaterialValue(value: material),
            forKey: getMaterialCacheKey(entity: entity)
        )
        
        return material
    }
    
    /// 특정 텍스트가 포함된 이미지를 생성한다
    // TODO: 하이파이 디자인에 맞게 카드 이미지, 폰트 등 세팅 필요함
    private func imageFrom(
        text: NSAttributedString,
        font: UIFont,
        size: CGSize,
        textColor: UIColor = .black
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // 배경 그리기
            Self.cardBackgroundColor.setFill() // TODO: 의미있나?
            context.fill(CGRect(origin: .zero, size: size))
            
            // 텍스트 크기 계산
            let textRect = CGRect(origin: .zero, size: size)
            let attributedText = text
            attributedText.draw(in: textRect)
        }
        
        return image
    }
    
    /// UIImage를 CGImage로 변환하고, RealityKit 텍스쳐로 반환한다.
    @MainActor
    private func convertImageToMaterial(from image: UIImage, baseMaterial: PhysicallyBasedMaterial?) async throws -> Material {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "CGImage 변환 실패"])
        }

        let texture = try await TextureResource.generate(
            from: cgImage,
            withName: nil,
            options: .init(semantic: .normal, compression: .default)
        )
        // CAUTION: Deprecated되어 `'init(image:withName:options:)'`를 사용하라는 경고가 발생하지만 사용하면 BAD_ACCESS 예외가 발생
        
        var material = baseMaterial ?? PhysicallyBasedMaterial()
        material.baseColor = .init(texture: MaterialParameters.Texture(texture))
        return material
    }
    
    private func getMaterialCacheKey(entity: Entity) -> NSString {
        NSString(string: "\(entity.id)")
    }
    
    private func extractBaseMaterial(from entity: Entity) -> Material? {
        guard let baseMaterialComponent = entity.components[ModelComponent.self] else {
            return nil
        }
        
        return baseMaterialComponent.materials.first
    }
}

fileprivate class MaterialValue: NSObject {
    let value: Material
    
    init(value: Material) {
        self.value = value
    }
}
