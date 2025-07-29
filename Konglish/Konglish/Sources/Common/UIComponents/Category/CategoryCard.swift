//
//  LevelCard.swift
//  Konglish
//
//  Created by Apple MacBook on 7/22/25.
//

import SwiftUI

/// 카테고리 카드
struct CategoryCard: View {
    
    // MARK: - Property
    let categoryModel: CategoryModel
    let action: () -> Void
    
    // MARK: - Property
    fileprivate enum CategoryConstants {
        static let cardInfoVspacing: CGFloat = 8
        static let cardContetnsVspacing: CGFloat = 12
    }
    
    // MARK: - Init
    init(categoryModel: CategoryModel, action: @escaping () -> Void) {
        self.categoryModel = categoryModel
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        ButtonCard(content: {
            cardContetns
        }, action: {
            action()
        })
    }
    
    // MARK: - Top
    /// 카드 내부 컨텐츠
    private var cardContetns: some View {
        VStack(spacing: CategoryConstants.cardContetnsVspacing, content: {
            Image(categoryModel.imageName)
            cardInfo
        })
    }
    
    // MARK: - Bottom
    /// 카드 하단 정보
    private var cardInfo: some View {
        VStack(spacing: CategoryConstants.cardInfoVspacing, content: {
            Star(count: categoryModel.difficulty)
            title
            subTitle
        })
    }
    
    /// 카테고리 제목
    private var title: some View {
        Text(categoryModel.nameKor)
            .font(.bold32)
            .foregroundStyle(Color.gray03)
    }
    
    /// 카테고리 영어 제목
    private var subTitle: some View {
        Text(categoryModel.nameEng)
            .font(.bold20)
            .foregroundStyle(Color.gray02)
    }
}

#Preview {
    CategoryCard(categoryModel: .init(imageName: "", difficulty: 2, nameKor: "1", nameEng: "1"), action: {
        print("hello")
    })
}
