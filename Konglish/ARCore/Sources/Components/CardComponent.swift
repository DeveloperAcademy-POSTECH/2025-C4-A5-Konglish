//
//  CardComponent.swift
//  ARCore
//
//  Created by 임영택 on 7/24/25.
//

import RealityKit
import UIKit

struct CardComponent: Component {
    // MARK: - Properties
    /// 카드 데이터
    let cardData: GameCard
    
    /// 카드 앞면/뒷면 상태 (false: 뒷면, true: 앞면)
    var isFlipped: Bool
    
    /// 카드 발음 성공/실패 상태 (false: 미도전, 실패, true: 성공)
    var isCompleted: Bool
    
    /// 텍스쳐에 들어갈 AttributedString
    var attributedText: NSAttributedString {
        let wordEng = NSAttributedString(
            string: cardData.wordEng + "\n",
            attributes: [
                .foregroundColor: UIColor.black,
                .font: UIFont.systemFont(ofSize: 64, weight: .bold)
            ]
        )
        let wordKor = NSAttributedString(
            string: cardData.wordKor,
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
    
    init(cardData: GameCard, isFlipped: Bool = false, isCompleted: Bool = false) {
        self.cardData = cardData
        self.isFlipped = isFlipped
        self.isCompleted = isCompleted
    }
}
