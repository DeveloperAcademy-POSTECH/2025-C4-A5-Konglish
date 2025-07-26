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
    
    /// 앞면 엔티티 이름
    private static let planeEntityName = "PlaneFront"
    
    /// 카드 너비
    static let cardWidth: Double = 680
    
    /// 카드 높이
    static let cardHeight: Double = 440
    
    /// 너비와 높이 가지고 이미지 해상도를 계산할 떄 사용하는 인자
    static let scaleFactor: Double = 4
    
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
                if child.name == Self.planeEntityName {
                    if let modelEntity = child.children.first as? ModelEntity,
                       let cardData = entity.components[CardComponent.self]?.cardData { // Nested `Plane`
                        
                        Task { @MainActor in
                            modelEntity.model?.materials = [
                                await createContentMaterial(for: modelEntity, cardData: cardData)
                            ]
                        }
                    }
                }
            }
        }
    }
    
    @MainActor
    private func createContentMaterial(for entity: HasModel, cardData: GameCard) async -> Material {
        // Load Cache
        if let cached = materialsCache.object(
            forKey: getMaterialCacheKey(entity: entity)
        ) {
            logger.debug("used cached material for entity=\(entity.id)")
            return cached.value
        }
        
        let image = imageFrom(
            engTitle: cardData.wordEng,
            korTitle: cardData.wordKor,
            image: cardData.image,
            size: .init(width: scale(Self.cardWidth), height: scale(Self.cardHeight))
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
        engTitle: String,
        korTitle: String,
        image: UIImage,
        size: CGSize,
        textColor: UIColor = .black
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            // 배경 그리기
            Self.cardBackgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 이미지
            let imageRect = CGRect(
                origin: .init(x: scale(40), y: scale(80)),
                size: .init(width: scale(280), height: scale(280))
            )
            image.draw(in: imageRect)
            
            // 단락 스타일
            let paragraphStyle: NSMutableParagraphStyle = {
                let style = NSMutableParagraphStyle()
                style.alignment = .center
                return style
            }()
            
            // 영문 텍스트
            let engTextRect = CGRect(
                origin: .init(x: scale(336), y: scale(116)),
                size: .init(width: scale(304), height: scale(80))
            )
            let engAttributedText = NSAttributedString(string: engTitle, attributes: [
                .font: UIFont.arCoreTitle.withSize(scale(UIFont.arCoreTitle.pointSize)),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.black,
                .strokeColor: UIColor.white,
                .strokeWidth: -10,
            ])
            engAttributedText.draw(in: engTextRect)
            
            // 국문 텍스트
            let korTextRect = CGRect(
                origin: .init(x: scale(336), y: scale(280)),
                size: .init(width: scale(304), height: scale(47))
            )
            let korAttributedText = NSAttributedString(string: korTitle, attributes: [
                .font: UIFont.arCoreSubtitle.withSize(scale(UIFont.arCoreSubtitle.pointSize)),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.black,
                .strokeColor: UIColor.white,
                .strokeWidth: -6,
            ])
            korAttributedText.draw(in: korTextRect)
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
        material.baseColor = .init(texture: MaterialParameters.Texture(texture)) // 원래 카드 엔티티 텍스쳐를 추출해 baseColor만 변경
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
    
    private func scale(_ scalar: Double) -> Double {
        scalar * Self.scaleFactor
    }
}

fileprivate class MaterialValue: NSObject {
    let value: Material
    
    init(value: Material) {
        self.value = value
    }
}
