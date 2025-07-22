//
//  CategoryModel.swift
//  Konglish
//
//  Created by Apple MacBook on 7/21/25.
//

import Foundation
import SwiftData

/// 카테고리 선택 시 보이는 카드 정보
@Model
final class CategoryModel {
    @Attribute(.unique) var id: UUID
    var imageName: String
    var difficulty: Int
    var nameKor: String
    var nameEng: String
    
    @Relationship(deleteRule: .cascade) var levels: [LevelModel] = []
    @Relationship(deleteRule: .cascade) var cards: [CardModel] = []
    
    init(id: UUID = UUID(), imageName: String, difficulty: Int, nameKor: String, nameEng: String) {
        self.id = id
        self.imageName = imageName
        self.difficulty = difficulty
        self.nameKor = nameKor
        self.nameEng = nameEng
    }
}
