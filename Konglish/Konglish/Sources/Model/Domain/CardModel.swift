//
//  CardModel.swift
//  Konglish
//
//  Created by Apple MacBook on 7/21/25.
//

import Foundation
import SwiftData

/// 게임에서 사용하는 영단어 카드 모델
@Model
final class CardModel {
    @Attribute(.unique) var id: UUID
    var imageName: String
    var pronunciation: String
    var wordKor: String
    var wordEng: String

    @Relationship(inverse: \CategoryModel.cards) var category: CategoryModel
    
    init(id: UUID = UUID(), imageName: String, pronunciation: String, wordKor: String, wordEng: String, category: CategoryModel) {
        self.id = id
        self.imageName = imageName
        self.pronunciation = pronunciation
        self.wordKor = wordKor
        self.wordEng = wordEng
        self.category = category
    }
}
