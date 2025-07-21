//
//  CategoryModel.swift
//  Konglish
//
//  Created by Apple MacBook on 7/21/25.
//

import Foundation
import SwiftData
import SwiftUI

/// 카테고리 선택 시 보이는 카테고리
@Model
final class CategoryModel {
    @Attribute(.unique) var id: UUID
    var imageName: ImageResource
    var nameKor: String
    var nameEng: String
    
    @Relationship(deleteRule: .cascade) var levels: [LevelModel] = []
    @Relationship(deleteRule: .cascade) var cards: [CardModel] = []
    
    init(id: UUID = UUID(), imageName: ImageResource, nameKor: String, nameEng: String) {
            self.id = id
            self.imageName = imageName
            self.nameKor = nameKor
            self.nameEng = nameEng
        }
}
