//
//  GameCard.swift
//  ARCore
//
//  Created by 임영택 on 7/21/25.
//

import Foundation

/// 카드에 들어가는 데이터를 표현하는 구조체
public struct GameCard {
    /// 카드의 아이디. CardModel의 ID와 동일하게 지정한다.
    public let id: UUID
    
    /// 이미지 이름. 이미지는 Assets에서 찾는다.
    public let imageName: String?
    
    /// 한국어 뜻
    public let wordKor: String
    
    /// 영어 철자
    public let wordEng: String
    
    public init(id: UUID, imageName: String?, wordKor: String, wordEng: String) {
        self.id = id
        self.imageName = imageName
        self.wordKor = wordKor
        self.wordEng = wordEng
    }
}
