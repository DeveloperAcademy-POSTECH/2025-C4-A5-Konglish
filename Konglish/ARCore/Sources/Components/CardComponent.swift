//
//  CardComponent.swift
//  ARCore
//
//  Created by 임영택 on 7/24/25.
//

import RealityKit

struct CardComponent: Component {
    // MARK: - Properties
    /// 카드 데이터
    let cardData: GameCard
    
    /// 카드 앞면/뒷면 상태 (false: 뒷면, true: 앞면)
    var isFlipped: Bool
    
    /// 카드 발음 성공/실패 상태 (false: 미도전, 실패, true: 성공)
    var isCompleted: Bool
    
    init(cardData: GameCard, isFlipped: Bool = false, isCompleted: Bool = false) {
        self.cardData = cardData
        self.isFlipped = isFlipped
        self.isCompleted = isCompleted
    }
}
