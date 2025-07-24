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
    var isFlipped: Bool = true
    
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
}
