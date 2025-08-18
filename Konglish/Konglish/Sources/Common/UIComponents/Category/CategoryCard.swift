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
                .resizable()
                .frame(width: 230, height: 230)
            cardInfo
        })
    }
    
    // MARK: - Bottom
    /// 카드 하단 정보
    private var cardInfo: some View {
        VStack(spacing: CategoryConstants.cardInfoVspacing, content: {
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
    }
    
    /// 카테고리 영어 제목
    private var subTitle: some View {
        Text(categoryModel.nameEng)
            .font(.bold20)
            .foregroundStyle(Color.gray02)
    }
}

#Preview {
    CategoryCard(categoryModel: .init(imageName: "", nameKor: "1", nameEng: "1"), action: {
        print("hello")
    })
}
