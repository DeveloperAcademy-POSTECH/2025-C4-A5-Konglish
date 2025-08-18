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
        static let starAndKorSpacing: CGFloat = 12
        static let KorAndEngSpacing: CGFloat = 8
    }
    
    // MARK: - Init
    init(categoryModel: CategoryModel, action: @escaping () -> Void) {
        self.categoryModel = categoryModel
        self.action = action
    }
    
    // MARK: - Body
    var body: some View {
        ButtonCard(content: {
            cardContents
        }, action: {
            action()
        })
    }
    
    // MARK: - Top
    /// 카드 이미지, 별, 한글명
    private var cardContents: some View {
        VStack(spacing: 0, content: {
            Image(categoryModel.imageName)
                .resizable()
                .frame(width: 230, height: 230)
            Star(count: clearedLevelCount)
            title
            subTitle
        })
    }
    
    /// 클리어된 레벨 수 계산
    private var clearedLevelCount: Int {
        // 해당 카테고리의 레벨들 중 bestScore > 0인 레벨 수를 계산
        let clearedLevels = categoryModel.levels.filter { $0.bestScore > 0 }
        return clearedLevels.count
    }
    
    /// 카테고리 제목
    private var title: some View {
        Text(categoryModel.nameKor)
            .font(.bold32)
            .foregroundStyle(Color.gray04)
            .padding(.top, CategoryConstants.starAndKorSpacing)
    }
    
    /// 카테고리 영어 제목
    private var subTitle: some View {
        Text(categoryModel.nameEng)
            .font(.bold20)
            .foregroundStyle(Color.gray02)
            .padding(.top, CategoryConstants.KorAndEngSpacing)
    }
}

#Preview {
    CategoryCard(categoryModel: .init(imageName: "", nameKor: "1", nameEng: "1"), action: {
        print("hello")
    })
}
