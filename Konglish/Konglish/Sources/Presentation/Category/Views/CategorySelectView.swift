//
//  CategorySelectView.swift
//  Konglish
//
//  Created by Apple MacBook on 7/28/25.
//

import SwiftUI
import SwiftData

struct CategorySelectView: View {
    
    @Query var category: [CategoryModel]
    
    fileprivate enum CategorySelectConstants {
        static let hspacing: CGFloat = 64
        static let naviHspacing: CGFloat = 56
        static let naviTitle: String = "카테고리 선택"
    }
    var body: some View {
        ZStack {
            Color.green02.ignoresSafeArea()
            
            LazyHStack(spacing: CategorySelectConstants.hspacing, content: {
                ForEach(category, id: \.self) { category in
                    CategoryCard(categoryModel: category, action: {
                        // TODO: - EnvrionmentInject Level
                    })
                }
            })
            .fixedSize()
            
        }
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading, content: {
                topNavi
            })
        })
    }
    
    private var topNavi: some View {
        HStack(spacing: CategorySelectConstants.naviHspacing, content: {
            MainButton(buttonType: .icon(.back), action: {
                // TODO: - EnvrionmentInject Level
            })
            
            Text(CategorySelectConstants.naviTitle)
                .font(.semibold64)
                .foregroundStyle(Color.green09)
        })
    }
}

#Preview {
    CategorySelectView()
}
