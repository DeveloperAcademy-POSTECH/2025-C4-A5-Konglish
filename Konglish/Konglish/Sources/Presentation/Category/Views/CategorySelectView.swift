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
    
    @Query var category: [CategoryModel]
    @EnvironmentObject var container: DIContainer
    
    fileprivate enum CategorySelectConstants {
        static let hspacing: CGFloat = 64
        static let naviHspacing: CGFloat = 56
        static let naviTitle: String = "카테고리 선택"
    }
    var body: some View {
        ZStack {
            Color.green01.ignoresSafeArea()
            
            LazyHStack(spacing: CategorySelectConstants.hspacing, content: {
                ForEach(category, id: \.self) { category in
                    CategoryCard(categoryModel: category, action: {
                        container.navigationRouter.push(.level(categoryId: category.id))
                    })
                }
            })
            .fixedSize()
            
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
