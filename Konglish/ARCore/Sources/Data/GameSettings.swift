//
//  GameSettings.swift
//  ARCore
//
//  Created by 임영택 on 7/19/25.
//

public struct GameSettings {
    // MARK: - Properties
    
    /// 배치할 카드의 총 개수
    let numberOfCards: Int
    
    /// 인식할 평면의 최소 면적
    let minimumSizeOfPlane: Float
    
    public init(numberOfCards: Int, minimumSizeOfPlane: Float) {
        self.numberOfCards = numberOfCards
        self.minimumSizeOfPlane = minimumSizeOfPlane
    }
    
    // TODO: 단어 세트 카테고리, 레벨 등을 표현할 수 있는 속성을 포함한다.
}
