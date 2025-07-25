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

/// 실제 씬에 추가되는 학습 카드의 엔티티 (물리 충돌 지원)
class CardEntity: Entity, HasModel, HasPhysics, HasCollision {
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
        
        // 콜리젼
        self.components[CollisionComponent.self] = CollisionComponent(shapes: [.generateBox(size: [CardEntity.cardWidth, CardEntity.cardDepth, CardEntity.cardHeight])])
        
        // 동적 텍스쳐 지정을 위한 컴포넌트
        self.components[DynamicTextureComponent.self] = DynamicTextureComponent(cardData: cardData)
      
        // 물리 컴포넌트 추가 (충돌 감지용)
        setupPhysicsComponents()
        
        // 기본 텍스쳐
        self.model?.materials = [
            SimpleMaterial(color: Self.backgroundColor, isMetallic: false)
        ]
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
    
    // MARK: - Physics Setup
    
    /// 물리 및 충돌 컴포넌트 설정
    private func setupPhysicsComponents() {
        // 충돌 형태 정의 (카드 박스 모양)
        let cardShape = ShapeResource.generateBox(
            size: [CardEntity.cardWidth, CardEntity.cardDepth, CardEntity.cardHeight]
        )
        
        // 물리 바디 컴포넌트 (고정 객체로 설정)
        let physicsMaterial = PhysicsMaterialResource.generate(
            staticFriction: 0.8,    // 높은 정적 마찰 (카드가 벽에 붙어있도록)
            dynamicFriction: 0.6,   // 적당한 동적 마찰
            restitution: 0.1        // 낮은 반발력 (튀지 않도록)
        )
        
        let physicsBody = PhysicsBodyComponent(
            massProperties: .default,
            material: physicsMaterial,
            mode: .kinematic  // 중요: kinematic으로 설정하여 고정되지만 충돌 감지 가능
        )
        
        self.components[PhysicsBodyComponent.self] = physicsBody
        
        // 충돌 컴포넌트 (트리거 모드로 설정)
        let collisionComponent = CollisionComponent(
            shapes: [cardShape],
            mode: .trigger  // 물리적 충돌 없이 이벤트만 발생
        )
        
        self.components[CollisionComponent.self] = collisionComponent
    }
}
