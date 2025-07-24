//
//  CardEntity.swift
//  ARCore
//
//  Created by 임영택 on 7/21/25.
//

import Foundation
import RealityKit
import Combine
import UIKit
import os.log

/// 실제 씬에 추가되는 학습 카드의 엔티티
class CardEntity: Entity, HasModel {
    // MARK: - Type Properties
    /// 카드 너비
    static let cardWidth: Float = 0.255
    
    /// 카드 높이
    static let cardHeight: Float = 0.157
    
    /// 카드 두께
    static let cardDepth: Float = 0.01
    
    /// 카드 백그라운드 컬러
    static let backgroundColor = UIColor(named: "primary01") ?? .red
    
    // MARK: - Properties
    /// 카드 데이터
    let cardData: GameCard?
    
    /// 카드 앞면/뒷면 상태 (false: 뒷면, true: 앞면)
    var isFlipped: Bool = false
    
    /// 카드 발음 성공/실패 상태 (false: 미도전, 실패, true: 성공)
    var isCompleted: Bool = false
    
    private let logger = Logger.of("CardEntity")
    
    var displayLabelText: NSAttributedString {
        let wordEng = NSAttributedString(
            string: (cardData?.wordEng ?? "N/A") + "\n",
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 64, weight: .bold)
            ]
        )
        let wordKor = NSAttributedString(
            string: cardData?.wordKor ?? "N/A",
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 48, weight: .medium)
            ]
        )

        let combined = NSMutableAttributedString()
        combined.append(wordEng)
        combined.append(wordKor)
        
        return combined
    }
    
    public init(cardData: GameCard?) {
        self.cardData = cardData
        
        super.init()
        
        // 엔티티에 모델 추가
        self.components[ModelComponent.self] = ModelComponent(
            mesh: .generateBox(size: [CardEntity.cardWidth, CardEntity.cardDepth, CardEntity.cardHeight]),
            materials: []
        )
        
        // 컴포넌트 추가 (검색 목적)
        self.components[CardComponent.self] = CardComponent()
        
        // 텍스쳐 추가
        let image = imageFrom(
            text: displayLabelText,
            font: .systemFont(ofSize: 24),
            size: CGSize(
                width: Double(CardEntity.cardWidth) * 1000.0,
                height: Double(CardEntity.cardHeight) * 1000.0
            ),
        )
        
        Task {
            var material: Material
            do {
                material = try await createTextImageMaterial(from: image)
            } catch {
                let logMessage = "❌ CardEntity: failed to create text image material"
                    + "=> fallback texture will be applied."
                    + "error:"
                logger.error("\(logMessage) \(error)")
                material = SimpleMaterial(color: CardEntity.backgroundColor, isMetallic: false)
            }
            
            await MainActor.run {
                self.model?.materials = [material]
            }
        }
    }
    
    convenience init(cardData: GameCard?, position: SIMD3<Float>) {
        self.init(cardData: cardData)
        self.position = position
    }
    
    required convenience init() {
        self.init(cardData: nil)
    }
    
    /// 특정 텍스트가 포함된 이미지를 생성한다
    // TODO: 하이파이 디자인에 맞게 카드 이미지, 폰트 등 세팅 필요함
    func imageFrom(
        text: NSAttributedString,
        font: UIFont,
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
            let attributedText = text
            attributedText.draw(in: textRect)
        }
        
        return image
    }
    
    /// UIImage를 CGImage로 변환하고, RealityKit 텍스쳐로 반환한다.
    func createTextImageMaterial(from image: UIImage) async throws -> Material {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "CGImage 변환 실패"])
        }

        let texture = try await TextureResource.generate(from: cgImage, withName: nil, options: .init(semantic: .normal, compression: .default))
        // CAUTION: Deprecated되어 `'init(image:withName:options:)'`를 사용하라는 경고가 발생하지만 사용하면 BAD_ACCESS 예외가 발생
        
        var material = SimpleMaterial()
        material.color = .init(texture: MaterialParameters.Texture(texture))
        
        return material
    }
}
