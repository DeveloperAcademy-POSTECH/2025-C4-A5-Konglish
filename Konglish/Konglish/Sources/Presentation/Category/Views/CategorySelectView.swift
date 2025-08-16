//
//  CategorySelectView.swift
//  Konglish
//
//  Created by Apple MacBook on 7/28/25.
//

import SwiftUI
import SwiftData
import Dependency

struct CategorySelectView: View {
    
    @Query var allCategories: [CategoryModel]
    @EnvironmentObject var container: DIContainer
    
    // 각 카테고리별로 클리어된 최고 레벨만 필터링
    private var filteredCategories: [CategoryModel] {
        // nameKor로 그룹핑
        let grouped = Dictionary(grouping: allCategories) { $0.nameKor }
        return grouped.compactMap { (categoryName, categories) in
            // 해당 카테고리의 레벨들을 difficulty 순으로 정렬
            let sortedCategories = categories.sorted { $0.difficulty < $1.difficulty }
            
            // bestScore > 0인 가장 높은 레벨 찾기
            var highestClearedLevel: CategoryModel?
            for category in sortedCategories.reversed() {
                
                // 해당 카테고리의 레벨 중에서 bestScore > 0인지 확인
                let levelType = difficultyToLevelType(category.difficulty)
                if category.levels.contains(where: { $0.bestScore > 0 && $0.levelNumber == levelType }) {
                    highestClearedLevel = category
                    break
                }
            }
            
            // 클리어된 레벨이 있으면 그것을, 없으면 레벨 1을 반환
            return highestClearedLevel ?? sortedCategories.first
        }.sorted { $0.nameKor < $1.nameKor }
        
        // difficulty Int를 LevelType으로 변환
        func difficultyToLevelType(_ difficulty: Int) -> LevelType {
            switch difficulty {
            case 1:
                return .easy
            case 2:
                return .normal
            case 3:
                return .hard
            default:
                return .easy
            }
        }
    }
    
    fileprivate enum CategorySelectConstants {
        static let hspacing: CGFloat = 64
        static let naviHspacing: CGFloat = 56
        static let naviTitle: String = "카테고리 선택"
    }
    var body: some View {
        ZStack {
            Color.green01.ignoresSafeArea()
            
            ScrollView(.horizontal) {
                LazyHStack(spacing: CategorySelectConstants.hspacing, content: {
                    ForEach(filteredCategories, id: \.self) { category in
                        CategoryCard(categoryModel: category, action: {
                            container.navigationRouter.push(.level(categoryId: category.id))
                            print(category.imageName)
                            print(category.id)
                        })
                    }
                })
                .padding(.horizontal, 113)
                .fixedSize()
            }
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .overlay(alignment: .topLeading, content: {
            topNavi
        })
    }
    
    private var topNavi: some View {
        HStack(spacing: CategorySelectConstants.naviHspacing, content: {
            MainButton(buttonType: .icon(.back), action: {
                container.navigationRouter.pop()
            })
            
            Text(CategorySelectConstants.naviTitle)
                .font(.semibold64)
                .foregroundStyle(Color.green09)
        })
        .safeAreaPadding(.leading, UIConstants.naviLeadingPadding)
    }
}

#Preview {
    CategorySelectView()
}
